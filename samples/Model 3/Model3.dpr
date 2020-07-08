program Model3;

uses Horse, Horse.SlowDown;

var
  App: THorse;
  Config: TSlowDownConfig;
begin
  App := THorse.Create(9000);

  Config.Id := 'ping';        // Identification
  Config.DelayAfter := 10;    // Delay after 60 Request
  Config.DelayMs := 500;      // Timeout of Delay
  Config.MaxDelayMs := 20000; // MaxDelay of 20 seconds
  Config.Timeout := 60;       // Timeout in seconds to Reset
  Config.Store := nil;        // Default TMemoryStore

  App.Get('/ping', THorseSlowDown.New(Config).limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  App.Start;
end.
