#!/usr/bin/env python3
"""Debug script to capture raw Arrow IPC data from Cube server."""

import socket
import struct

def read_message(sock):
    """Read a length-prefixed message."""
    length_data = b''
    while len(length_data) < 4:
        chunk = sock.recv(4 - len(length_data))
        if not chunk:
            return None
        length_data += chunk

    length = struct.unpack('>I', length_data)[0]
    print(f"Message length: {length}")

    payload = b''
    while len(payload) < length:
        chunk = sock.recv(length - len(payload))
        if not chunk:
            break
        payload += chunk

    if len(payload) < length:
        return None
    return payload

def send_message(sock, msg_type, data):
    """Send a length-prefixed message."""
    payload = bytes([msg_type]) + data
    length = struct.pack('>I', len(payload))
    sock.sendall(length + payload)

def main():
    # Connect to Cube
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('localhost', 4445))
    print("Connected to Cube server")

    # Handshake (type=0, version=1)
    handshake_payload = struct.pack('>I', 1)  # Version 1 as U32
    send_message(sock, 0, handshake_payload)
    response = read_message(sock)
    if not response:
        print("ERROR: No handshake response")
        sock.close()
        return
    print(f"Handshake response: {len(response)} bytes")
    print(f"  Hex: {response.hex()}")

    # Auth (type=1, token="test", database=optional empty)
    token = b'test'
    database = b''
    auth_payload = struct.pack('>I', len(token)) + token  # String: length + data
    if database:
        auth_payload += b'\x01' + struct.pack('>I', len(database)) + database  # OptionalString: 1 + length + data
    else:
        auth_payload += b'\x00'  # OptionalString: 0 (no value)
    send_message(sock, 1, auth_payload)
    response = read_message(sock)
    if not response:
        print("ERROR: No auth response")
        sock.close()
        return
    print(f"Auth response: {len(response)} bytes")
    print(f"  Hex: {response.hex()}")

    # Query (type=2, sql=String)
    query = b'SELECT 1 as test, 2 as value'
    query_payload = struct.pack('>I', len(query)) + query  # String: length + data
    send_message(sock, 2, query_payload)

    # Read all responses
    all_arrow_data = b''
    msg_count = 0
    while True:
        response = read_message(sock)
        if not response:
            break

        msg_count += 1
        msg_type = response[0]
        print(f"\nMessage {msg_count}: type={msg_type}, size={len(response)-1}")

        if msg_type == 3:  # QueryResponseSchema
            arrow_data = response[1:]
            print(f"  Schema Arrow IPC data: {len(arrow_data)} bytes")
            print(f"  First 64 bytes: {arrow_data[:64].hex()}")
            all_arrow_data += arrow_data

        elif msg_type == 4:  # QueryResponseBatch
            arrow_data = response[1:]
            print(f"  Batch Arrow IPC data: {len(arrow_data)} bytes")
            print(f"  First 64 bytes: {arrow_data[:64].hex()}")
            all_arrow_data += arrow_data

        elif msg_type == 5:  # QueryComplete
            rows_affected_data = response[1:]
            rows_affected = struct.unpack('>Q', rows_affected_data)[0]
            print(f"  Query complete: {rows_affected} rows")
            break

        elif msg_type == 6:  # Error
            print(f"  Error: {response[1:].decode('utf-8', errors='replace')}")
            break

    sock.close()

    # Save Arrow data to file
    with open('/tmp/cube_arrow_data.bin', 'wb') as f:
        f.write(all_arrow_data)
    print(f"\n\nTotal Arrow IPC data: {len(all_arrow_data)} bytes")
    print(f"Saved to /tmp/cube_arrow_data.bin")

    # Analyze structure
    print("\n=== Arrow IPC Structure Analysis ===")
    offset = 0
    while offset < len(all_arrow_data):
        if offset + 8 > len(all_arrow_data):
            break

        # Try to read as continuation marker
        continuation = struct.unpack('<I', all_arrow_data[offset:offset+4])[0]
        msg_length = struct.unpack('<I', all_arrow_data[offset+4:offset+8])[0]

        print(f"\nOffset {offset}:")
        print(f"  Continuation: 0x{continuation:08x} ({'VALID' if continuation == 0xFFFFFFFF else 'INVALID'})")
        print(f"  Message length: {msg_length}")

        if continuation == 0xFFFFFFFF and msg_length > 0 and msg_length < 1000000:
            # Valid message header
            if offset + 8 + msg_length <= len(all_arrow_data):
                msg_data = all_arrow_data[offset+8:offset+8+msg_length]
                print(f"  Message data (first 32 bytes): {msg_data[:32].hex()}")
                offset += 8 + msg_length
                # Align to 8-byte boundary
                if offset % 8 != 0:
                    padding = 8 - (offset % 8)
                    offset += padding
            else:
                print(f"  ERROR: Message extends beyond buffer")
                break
        else:
            print(f"  Not a valid message header, advancing 1 byte")
            offset += 1

if __name__ == '__main__':
    main()
