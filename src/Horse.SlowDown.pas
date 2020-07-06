unit Horse.SlowDown;

interface

uses
  Horse,
  Horse.SlowDown.Config, Horse.SlowDown.Store.Intf, Horse.SlowDown.Store.Memory, Horse.SlowDown.Utils,
  System.SysUtils, System.Math,
  Web.HTTPApp;

const
  DEFAULT_DELAYAFTER = 60;
  DEFAULT_DELAYMS = 1000;
  DEFAULT_TIMEOUT = 60;

type
  TSlowDownConfig = Horse.SlowDown.Config.TSlowDownConfig;

  THorseSlowDown = class
  strict private
    FConfig: TSlowDownManager;
    class var FInstance: THorseSlowDown;
  public
    constructor Create(const AConfig: TSlowDownConfig); overload;
    constructor Create(const AId: string; const ADelayAfter, ADelayMs, ATimeout: Integer); overload;
    destructor Destroy; override;
    procedure Limit(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    property Manager: TSlowDownManager read FConfig write FConfig;

    class function New(const AConfig: TSlowDownConfig): THorseSlowDown; overload;
    class function New(const AId: string; const ADelayAfter: Integer = DEFAULT_DELAYAFTER; const ADelayMs: Integer = DEFAULT_DELAYMS; const ATimeout: Integer = DEFAULT_TIMEOUT): THorseSlowDown; overload;
    class function New(const ADelayAfter, ADelayMs, ATimeout: Integer): THorseSlowDown; overload;
    class function New(): THorseSlowDown; overload;
    class procedure FinalizeInstance;
  end;

implementation

{ THorseSlowDown }

constructor THorseSlowDown.Create(const AConfig: TSlowDownConfig);
begin
  FConfig := TSlowDownManager.New(AConfig);
end;

constructor THorseSlowDown.Create(const AId: string; const ADelayAfter, ADelayMs, ATimeout: Integer);
begin
  FConfig := TSlowDownManager.New(AId, ADelayAfter, ADelayMs, ATimeout);
end;

destructor THorseSlowDown.Destroy;
begin
  FConfig.Free;
  inherited;
end;

class function THorseSlowDown.New(const AConfig: TSlowDownConfig): THorseSlowDown;
var
  LConfig: TSlowDownConfig;
begin
  if not(Assigned(FInstance)) then
    FInstance := THorseSlowDown.Create(AConfig)
  else
    FInstance.Manager := TSlowDownManager.New(AConfig);

  if not(Assigned(FInstance.Manager.Config.Store)) then
  begin
    LConfig := FInstance.Manager.Config;
    LConfig.Store := TMemoryStore.Create(FInstance.Manager.Config.Timeout);
    FInstance.Manager.Config := LConfig;
  end;

  Result := FInstance;
end;

class function THorseSlowDown.New(const AId: string; const ADelayAfter: Integer = DEFAULT_DELAYAFTER; const ADelayMs: Integer = DEFAULT_DELAYMS; const ATimeout: Integer = DEFAULT_TIMEOUT): THorseSlowDown;
var
  LConfig: TSlowDownConfig;
begin
  if not(Assigned(FInstance)) then
    FInstance := THorseSlowDown.Create(AId, ADelayAfter, ADelayMs, ATimeout)
  else
    FInstance.Manager := TSlowDownManager.New(AId, ADelayAfter, ADelayMs, ATimeout);

  if not(Assigned(FInstance.Manager.Config.Store)) then
  begin
    LConfig := FInstance.Manager.Config;
    LConfig.Store := TMemoryStore.Create(FInstance.Manager.Config.Timeout);
    FInstance.Manager.Config := LConfig;
  end;

  Result := FInstance;
end;

class function THorseSlowDown.New(const ADelayAfter, ADelayMs, ATimeout: Integer): THorseSlowDown;
begin
  Result := New('', ADelayAfter, ADelayMs, ATimeout);
end;

class function THorseSlowDown.New(): THorseSlowDown;
begin
  Result := New('');
end;

class procedure THorseSlowDown.FinalizeInstance;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

procedure THorseSlowDown.Limit(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LStoreCallback: TSlowDownStoreCallback;
  LKey: string;
  LTimeSleep: Int64;
begin
  LKey := 'SD' + Manager.Config.Id + ClientIP(Req);

  LStoreCallback := Manager.Config.Store.Incr(LKey);

  if (LStoreCallback.Current > Manager.Config.DelayAfter) then
  begin
    LTimeSleep := Manager.Config.DelayMs * (LStoreCallback.Current - Manager.Config.DelayAfter);

    if (Manager.Config.MaxDelayMs > 0) then
      if (LTimeSleep > Manager.Config.MaxDelayMs) then
        LTimeSleep := Manager.Config.MaxDelayMs;

    Sleep(LTimeSleep);
  end;

  try
    Next;
  except
    Manager.Config.Store.Decrement(LKey);
    Exit;
  end;

  Manager.Save;
end;

initialization

finalization

THorseSlowDown.FinalizeInstance;

end.
