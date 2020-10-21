program Model4;

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
