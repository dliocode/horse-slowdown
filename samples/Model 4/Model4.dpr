program Model4;

uses Horse, Horse.SlowDown, Store.Redis;

var
  App: THorse;
begin
  App := THorse.Create(9000);

  App.Use(THorseSlowDown.New(10, 500, 60, TRedisStore.New()).Limit);

  App.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  App.Start;
end.
