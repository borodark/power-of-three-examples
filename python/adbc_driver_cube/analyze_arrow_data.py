#!/usr/bin/env python3
"""Analyze the Arrow IPC data from Cube using PyArrow."""

import pyarrow as pa

# Read the binary data
with open('/tmp/cube_arrow_ipc_data.bin', 'rb') as f:
    data = f.read()

print(f"Total data size: {len(data)} bytes")
print(f"Hex dump of first 256 bytes:")
for i in range(0, min(len(data), 256), 16):
    hex_str = ' '.join(f'{b:02x}' for b in data[i:i+16])
    ascii_str = ''.join(chr(b) if 32 <= b < 127 else '.' for b in data[i:i+16])
    print(f"  {i:04x}: {hex_str:<48} {ascii_str}")

print("\n" + "="*60)
print("Attempting to parse as Arrow IPC stream...")
print("="*60)

try:
    # Try to read as an Arrow IPC stream
    import io
    stream = io.BytesIO(data)
    reader = pa.ipc.open_stream(stream)

    print(f"\nSchema:")
    print(reader.schema)

    print(f"\nReading batches:")
    batch_num = 0
    for batch in reader:
        batch_num += 1
        print(f"\nBatch {batch_num}:")
        print(f"  Num rows: {len(batch)}")
        print(f"  Num columns: {len(batch.columns)}")
        for i, col in enumerate(batch.columns):
            print(f"  Column {i} ({batch.schema[i].name}): {col.to_pylist()}")

        # Convert to table
        table = pa.Table.from_batches([batch])
        print(f"\nTable:")
        print(table.to_pandas())

    print(f"\nTotal batches read: {batch_num}")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()

print("\n" + "="*60)
print("Manual structure analysis:")
print("="*60)

offset = 0
msg_num = 0
while offset < len(data):
    if offset + 8 > len(data):
        print(f"\nOffset {offset:04x}: Not enough data for header ({len(data)-offset} bytes remaining)")
        break

    continuation = int.from_bytes(data[offset:offset+4], 'little')
    msg_size = int.from_bytes(data[offset+4:offset+8], 'little')

    print(f"\nMessage {msg_num} at offset {offset:04x}:")
    print(f"  Continuation: 0x{continuation:08x} ({'VALID' if continuation == 0xFFFFFFFF else 'INVALID/EOS' if continuation == 0xFFFFFFFF else 'OTHER'})")
    print(f"  Size: {msg_size} bytes (0x{msg_size:x})")

    if continuation == 0xFFFFFFFF:
        if msg_size == 0:
            print(f"  Type: END OF STREAM marker")
            offset += 8
        elif msg_size > 0 and msg_size < 10000:
            msg_end = offset + 8 + msg_size
            if msg_end <= len(data):
                msg_data = data[offset+8:msg_end]
                print(f"  Message data (first 32 bytes): {msg_data[:32].hex()}")

                # Try to find ASCII strings in the message
                ascii_strings = []
                current_str = []
                for b in msg_data:
                    if 32 <= b < 127:
                        current_str.append(chr(b))
                    else:
                        if len(current_str) >= 3:
                            ascii_strings.append(''.join(current_str))
                        current_str = []
                if len(current_str) >= 3:
                    ascii_strings.append(''.join(current_str))

                if ascii_strings:
                    print(f"  Strings found: {ascii_strings}")

                # Advance to next 8-byte boundary
                offset = msg_end
                if offset % 8 != 0:
                    padding = 8 - (offset % 8)
                    print(f"  Padding: {padding} bytes")
                    offset += padding
            else:
                print(f"  ERROR: Message extends beyond buffer")
                break
        else:
            print(f"  ERROR: Invalid message size")
            break
    else:
        print(f"  Not a valid continuation marker")
        offset += 4

    msg_num += 1
    if msg_num > 20:
        print("\n... (stopping after 20 messages)")
        break
