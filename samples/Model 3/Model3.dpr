program Model3;

uses
  Horse, Horse.SlowDown;

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
  .Get('/ping', THorseSlowDown.New(Config),
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000);
end.
