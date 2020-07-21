unit Horse.SlowDown;

interface

uses
  Horse,
  Horse.SlowDown.Config, Horse.SlowDown.Utils,
  Store.Intf, Store.Memory,
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
    constructor Create(const AId: string; const ADelayAfter, ADelayMs, ATimeout: Integer; const AStore: IStore); overload;
    destructor Destroy; override;
    procedure Limit(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    property Manager: TSlowDownManager read FConfig write FConfig;

    class function New(const AConfig: TSlowDownConfig): THorseSlowDown; overload;
    class function New(const AId: string; const ADelayAfter: Integer = DEFAULT_DELAYAFTER; const ADelayMs: Integer = DEFAULT_DELAYMS; const ATimeout: Integer = DEFAULT_TIMEOUT; const AStore: IStore = nil): THorseSlowDown; overload;
    class function New(const ADelayAfter, ADelayMs, ATimeout: Integer; const AStore: IStore = nil): THorseSlowDown; overload;
    class function New(): THorseSlowDown; overload;
    class procedure FinalizeInstance;
  end;

implementation

{ THorseSlowDown }

constructor THorseSlowDown.Create(const AConfig: TSlowDownConfig);
begin
  FConfig := TSlowDownManager.New(AConfig);
end;

constructor THorseSlowDown.Create(const AId: string; const ADelayAfter, ADelayMs, ATimeout: Integer; const AStore: IStore);
begin
  FConfig := TSlowDownManager.New(AId, ADelayAfter, ADelayMs, ATimeout, AStore);
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
    LConfig.Store := TMemoryStore.New();
    FInstance.Manager.Config := LConfig;
  end;

  FInstance.Manager.Config.Store.SetTimeout(FInstance.Manager.Config.Timeout);

  Result := FInstance;
end;

class function THorseSlowDown.New(const AId: string; const ADelayAfter: Integer = DEFAULT_DELAYAFTER; const ADelayMs: Integer = DEFAULT_DELAYMS; const ATimeout: Integer = DEFAULT_TIMEOUT; const AStore: IStore = nil): THorseSlowDown;
var
  LConfig: TSlowDownConfig;
begin
  if not(Assigned(FInstance)) then
    FInstance := THorseSlowDown.Create(AId, ADelayAfter, ADelayMs, ATimeout, AStore)
  else
    FInstance.Manager := TSlowDownManager.New(AId, ADelayAfter, ADelayMs, ATimeout, AStore);

  if not(Assigned(FInstance.Manager.Config.Store)) then
  begin
    LConfig := FInstance.Manager.Config;
    LConfig.Store := TMemoryStore.New();
    FInstance.Manager.Config := LConfig;
  end;

  FInstance.Manager.Config.Store.SetTimeout(FInstance.Manager.Config.Timeout);

  Result := FInstance;
end;

class function THorseSlowDown.New(const ADelayAfter, ADelayMs, ATimeout: Integer; const AStore: IStore = nil): THorseSlowDown;
begin
  Result := New('', ADelayAfter, ADelayMs, ATimeout, AStore);
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
  LStoreCallback: TStoreCallback;
  LKey: string;
  LTimeSleep: Int64;
begin
  LKey := 'SD:' + Manager.Config.Id + ':' + ClientIP(Req);

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
    raise;
  end;

  Manager.Save;
end;

initialization

finalization

THorseSlowDown.FinalizeInstance;

end.
