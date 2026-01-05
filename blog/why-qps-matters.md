# Why QPS Matters: The Hidden Metric That Makes or Breaks Your Analytics Platform

> *"At 3,500 queries per second, analysis becomes conversational."*

**TL;DR**: Switching from HTTP to ADBC increased our query throughput by **4,500x** - from 0.08 to 3,500 queries per second. This isn't just a number; it's the difference between waiting for answers and *thinking* with your data.

---

## The Metric Nobody Talks About

When evaluating analytics platforms, teams obsess over:
- Storage costs
- Query language features
- Visualization options
- Integration ecosystem

But there's one metric that determines whether your analytics platform actually *works* at scale: **Queries Per Second (QPS)**.

QPS measures how many queries your system can handle simultaneously. It's the throughput of your analytics engine - and it matters more than you think.

## The Real-World Problem

Picture this scenario:

Your company has 500 analysts hitting dashboards at 9 AM Monday morning. Each dashboard runs 10 queries to populate charts and KPIs. That's **5,000 queries** in the first few minutes.

With traditional HTTP-based analytics APIs delivering **0.08 QPS**, those queries would take:

```
5,000 queries ÷ 0.08 qps = 62,500 seconds = 17+ hours
```

Your Monday morning standup just became a Tuesday afternoon catchup.

## A Tale of Two "Soft Real-Times"

Joe Armstrong, the creator of Erlang, defined [soft real-time](https://erlang.org/pipermail/erlang-questions/2017-October/093931.html) as systems where "some requests might miss the deadlines" - as opposed to hard real-time where every request must complete within a guaranteed time window. Erlang was designed for [soft real-time with millisecond response times](https://erlang.org/download/erlang-book-part1.pdf).

We've discovered there's *another* kind of "soft real-time" in the analytics world:

> **Soft Real-Time (Erlang)**: Response times in milliseconds, occasionally missing tight deadlines.
>
> **Soft Real-Time (HTTP Analytics)**: Your data is "real-time" in the sense that it was real at *some* point in time. The spinning wheel animation is real-time though - you can watch every frame.

You know you're in "soft real-time" territory when your HTTP client needs this:

```elixir
@spinner_frames ["|", "/", "-", "\\"]

defp show_spinner(idx, elapsed_ms, max_wait_ms) do
  frame = Enum.at(@spinner_frames, idx)
  IO.write(:stderr, "\r#{frame} Cube processing... #{elapsed_s}s/#{max_s}s ")
end
```

☕ *With HTTP at 0.08 QPS, you have mass time to:*
- Get coffee
- Attend a standup
- Question your career choices
- Watch `| / - \` cycle 3,168 times (12.67 seconds ÷ 4ms per frame)
- Finally see results from data that's now 12 seconds staler

And here's the real kicker: **pre-aggregations add another layer of "softness."**

Pre-aggs deliver blazing fast queries, but the data was aggregated minutes (or hours) ago. So you're waiting 12 seconds... for data that was already 10 minutes old. That's not soft real-time. That's *nostalgia-as-a-service*.

ADBC fixes half this problem. Your queries return in milliseconds - actual Erlang-style soft real-time. The pre-aggregation staleness? Well, at least you find out about your stale data *instantly*.

## What We Discovered

We ran extensive saturation tests comparing HTTP REST APIs against ADBC (Arrow Database Connectivity) for Cube.js analytics queries. The results were staggering:

| Protocol | Throughput | Avg Latency | Concurrent Users |
|----------|------------|-------------|------------------|
| HTTP     | 0.08 qps   | 12,669 ms   | Bottlenecked     |
| ADBC     | 3,500 qps  | 0.4 ms      | 800+ sustained   |

**ADBC delivers 4,500x higher throughput.**

Let's revisit our Monday morning scenario with ADBC:

```
5,000 queries ÷ 3,500 qps = 1.4 seconds
```

From 17 hours to 1.4 seconds. That's not an optimization - that's a paradigm shift.

## Why HTTP Falls Short for Analytics

HTTP REST APIs weren't designed for high-throughput analytics workloads:

### 1. Serialization Overhead
Every HTTP request requires:
- JSON serialization on the server
- Network transmission of text data
- JSON parsing on the client

For a query returning 100,000 rows, this overhead dominates execution time.

### 2. Connection Establishment
HTTP/1.1 connections have setup costs. Even with keep-alive, the protocol wasn't designed for thousands of concurrent analytical queries.

### 3. Text-Based Protocol
JSON is human-readable but machine-inefficient. Numbers become strings, dates become strings, everything becomes strings - then gets parsed back.

## Why ADBC Changes Everything

ADBC (Arrow Database Connectivity) takes a fundamentally different approach:

### 1. Zero-Copy Data Transfer
Arrow's columnar format allows data to move from database to application without serialization. The bytes in memory ARE the data structure.

### 2. Native Binary Protocol
No JSON parsing. No string conversion. Binary data flows directly over the wire in Arrow IPC format.

### 3. Columnar Efficiency
Analytics queries typically access few columns across many rows. Arrow's columnar layout means you only transfer what you need.

### 4. Connection Pooling
ADBC connections are lightweight and poolable. We sustained 800 concurrent connections with 100% success rate.

## The Throughput Compound Effect

High QPS doesn't just make individual queries faster - it transforms what's possible:

### Interactive Exploration: Analysis Becomes Conversational

At 0.08 QPS, users wait. They context-switch. They check email. They lose their train of thought. By the time results arrive, they've forgotten why they asked.

At 3,500 QPS, something magical happens: **analysis becomes conversational.**

Click, see results, click again. Ask a follow-up question before you forget it. Drill down, pivot, explore. The data responds at the speed of thought - and thought is fast.

This isn't incremental improvement. It's a phase transition from "reporting tool" to "thinking partner."

### Real-Time Dashboards
```
Refresh Rate = 1 / Query Latency

HTTP:  1 / 12.669s = 0.08 refreshes/second (one refresh per 12 seconds)
ADBC:  1 / 0.0004s = 2,500 refreshes/second (effectively real-time)
```

### Concurrent Users at Scale
```
Max Concurrent Users = QPS × Acceptable Wait Time

HTTP:  0.08 × 3 seconds = 0.24 users (not even one!)
ADBC:  3,500 × 3 seconds = 10,500 users
```

### Cost Efficiency
Higher throughput means fewer servers for the same workload:

```
Servers Needed = Peak Queries / (QPS per Server)

For 10,000 peak queries:
HTTP:  10,000 / 0.08 = 125,000 servers (impossible)
ADBC:  10,000 / 3,500 = 3 servers
```

## Measuring QPS: What Good Looks Like

Based on our testing, here are QPS benchmarks for analytics platforms:

| QPS Range | Rating | User Experience |
|-----------|--------|-----------------|
| < 1       | Poor   | Frustrating, users abandon |
| 1-10      | Basic  | Usable for small teams |
| 10-100    | Good   | Comfortable for most use cases |
| 100-1000  | Great  | Smooth interactive analytics |
| 1000+     | Excellent | Real-time, unlimited scale |

ADBC puts you firmly in the "Excellent" category.

## The Latency-Throughput Connection

QPS and latency are two sides of the same coin:

```
QPS = Concurrent Connections / Average Latency
```

Our ADBC results:
```
3,500 qps = 800 connections / 0.23ms average latency
```

Low latency enables high throughput. High throughput enables scale. Scale enables business value.

## Implementing High-QPS Analytics

Here's how we achieved 3,500+ QPS with Elixir and ADBC:

### 1. Connection Pooling
```elixir
# Configure ADBC connection pool
config :my_app, Adbc.CubePool,
  pool_size: 44,  # Tune based on your workload
  host: "localhost",
  port: 8120
```

### 2. Efficient Query Execution
```elixir
def execute_query(sql) do
  # Get connection from pool (microseconds)
  conn = Adbc.CubePool.get_connection()

  # Execute query (sub-millisecond for cached)
  {:ok, result} = Adbc.Connection.query(conn, sql)

  # Results already in Arrow format - no parsing needed
  result
end
```

### 3. Leverage Pre-Aggregations
Pre-aggregated data + ADBC = maximum throughput:

| Configuration | QPS | Latency |
|--------------|-----|---------|
| No Pre-Agg + HTTP | 0.08 | 12,669ms |
| Pre-Agg + HTTP | 25 | 389ms |
| No Pre-Agg + ADBC | 350 | 2.8ms |
| Pre-Agg + ADBC | 3,500+ | 0.4ms |

## Key Takeaways

1. **QPS is the throughput metric** that determines analytics platform viability at scale

2. **HTTP REST APIs bottleneck** at ~0.1 QPS for complex analytics queries

3. **ADBC delivers 4,500x improvement** through binary protocols and zero-copy transfers

4. **High QPS enables**: real-time dashboards, concurrent users, interactive exploration, and cost efficiency

5. **Measure your QPS** before committing to an analytics architecture

## Try It Yourself

We've open-sourced our saturation testing framework. Run your own benchmarks:

```bash
# Clone the repository
git clone https://github.com/borodark/power-of-three-examples

# Run ADBC vs HTTP comparison
mix test test/saturation_test.exs --include live_cube

# Run endurance test (sustained load)
mix test test/saturation_test.exs --include endurance
```

## Conclusion

QPS isn't just a performance metric - it's a user experience metric, a scalability metric, and ultimately a business metric.

When your analytics platform delivers 3,500 queries per second instead of 0.08, you're not just 4,500x faster. You're enabling an entirely different relationship between humans and data:

- Dashboards that feel instant
- Exploration that flows naturally
- Insights that arrive in real-time
- Infrastructure costs that make sense

**But most importantly: analysis becomes conversational.**

Your data stops being something you query and starts being something you think with. That's not a performance optimization - that's a transformation in how decisions get made.

The future of analytics is high-throughput. ADBC gets you there today.

---

*This post is based on real benchmark data from our saturation testing suite. All tests were conducted with 100-800 concurrent connections over sustained periods. Your results may vary based on query complexity, data volume, and infrastructure.*

**Tags**: #analytics #performance #ADBC #Arrow #throughput #QPS #Elixir #CubeJS
