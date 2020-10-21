# Horse-SlowDown

![](https://img.shields.io/github/stars/dliocode/horse-slowdown.svg) ![](https://img.shields.io/github/forks/dliocode/horse-slowdown.svg) ![](https://img.shields.io/github/tag/dliocode/horse-slowdown.svg) ![](https://img.shields.io/github/release/dliocode/horse-slowdown.svg) ![](https://img.shields.io/github/issues/dliocode/horse-slowdown.svg)

Support: developer.dlio@gmail.com

Basic rate-limiting middleware for Horse. Use to limit repeated requests to public APIs and/or endpoints such as password reset.

### For install in your project using [boss](https://github.com/HashLoad/boss):
``` sh
$ boss install github.com/dliocode/horse-slowdown
```

### Stores

- Memory Store _(default, built-in)_ - stores current in-memory in the Horse process. Does not share state with other servers or processes.
- RedisStore: [Samples - Model 4](https://github.com/dliocode/horse-slowdown/tree/master/samples/Model%204)

## Usage

For an API-only server where the slowdown should be applied to all requests:
Ex: _Store Memory_

```delphi
uses Horse, Horse.SlowDown;

begin
  THorse
  .Use(THorseSlowDown.New().Limit)
  .Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000);
end.
```

Create multiple instances to different routes:
*Identification should always be used when using multiple instances.*

```delphi
uses Horse, Horse.SlowDown;

begin
  THorse.Get('/ping', THorseSlowDown.New('ping').limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end)

  .Get('/book', THorseSlowDown.New('book').limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('The book!');
    end)

  .Get('/login', THorseSlowDown.New('login',10,500,60).limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('My Login with Request Max of 10 every 60 seconds!');
    end);

  THorse.Listen(9000);
end.
```

Settings use:

```delphi
uses Horse, Horse.SlowDown;

var
  Config: TSlowDownConfig;
begin
  Config.Id := 'ping';        // Identification
  Config.DelayAfter := 10;    // Delay after 60 Request
  Config.DelayMs := 500;      // Timeout of Delay
  Config.MaxDelayMs := 20000; // MaxDelay of 20 seconds
  Config.Timeout := 60;       // Timeout in seconds to Reset
  Config.Store := nil;        // Default TMemoryStore

  THorse
  .Get('/ping', THorseSlowDown.New(Config).limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000);
end.
```

**Note:** most stores will require additional configuration, such as custom prefixes, when using multiple instances. The default built-in memory store is an exception to this rule.

## Configuration options

### Id
 
Identification should always be used when using multiple instances..

### DelayAfter

Max number of request during `Timeout` before starting to delay response..

It must be a number. The default is `60`.

### DelayMs

How long to delay the response, multiplied by (number of request - `DelayAfter`).

It must be a number. The default is `1000` (1 second).

### MaxDelayMs

Maximum value for `DelayMs` after many consecutive attempts.

Defaults to `0` (Infinity).

### Timeout

How long to keep records of request in memory.

Note: with non-default stores, you may need to configure this value twice, once here and once on the store. In some cases the units also differ (e.g. seconds vs miliseconds)

Defaults to `60` (1 minute).

### Store

The storage to use when persisting rate limit attempts.

By default, the MemoryStore is used.

Available data stores are:

- MemoryStore: _(default)_ Simple in-memory option. Does not share state when app has multiple processes or servers.
- RedisStore: [Samples - Model 4](https://github.com/dliocode/horse-slowdown/tree/master/samples/Model%204)

You may also create your own store. It must implement the IStore to function

### Store with Redis

Usage:

To use it you must add to uses `Store.Redis` with the function `TRedisStore.New()`.

Ex: _Store Redis_
```delphi
uses Horse, Horse.SlowDown, Store.Redis;

begin
  THorse
  .Use(THorseSlowDown.New(10, 500, 60, TRedisStore.New()).Limit)
  .Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000);
end.
```

How to configure host, port in Redis
`TRedisStore.New('HOST','PORT','NAME CLIENTE')`

1st Parameter - HOST - Default: `127.0.0.1`

2st Parameter - PORT - Default: `6379`

3st Parameter - ClientName - Default: `Empty`


## License

MIT © [Danilo Lucas](https://github.com/dliocode)
