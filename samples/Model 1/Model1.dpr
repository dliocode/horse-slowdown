program Model1;

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
