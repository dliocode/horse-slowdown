unit Horse.SlowDown.Config;

interface

uses
  Horse.SlowDown.Store.Intf, Horse.SlowDown.Memory,
  System.SysUtils;

type
  TSlowDownConfig = record
    Id: string;
    DelayAfter: Integer;
    DelayMs: Integer;
    MaxDelayMs: Integer;
    Timeout: Integer;
    Store: ISlowDownStore;
  end;

  TSlowDownManager = class
  strict private
    FDictionary: TMemoryDictionary<TSlowDownConfig>;
    FConfig: TSlowDownConfig;
    class var FInstance: TSlowDownManager;
  public
    constructor Create();
    destructor Destroy; override;

    function GetDictionary: TMemoryDictionary<TSlowDownConfig>;
    procedure Save;

    property Config: TSlowDownConfig read FConfig write FConfig;

    class function New(const AConfig: TSlowDownConfig): TSlowDownManager; overload;
    class function New(const AId: String; const ADelayAfter, ADelayMs, ATimeout: Integer): TSlowDownManager; overload;
    class procedure FinalizeInstance;
  end;

implementation

{ TSlowDownManager }

constructor TSlowDownManager.Create();
begin
  FDictionary := TMemoryDictionary<TSlowDownConfig>.Create;
end;

destructor TSlowDownManager.Destroy;
begin
  FDictionary.Free;
end;

class function TSlowDownManager.New(const AConfig: TSlowDownConfig): TSlowDownManager;
var
  LConfig: TSlowDownConfig;
begin
  if not(Assigned(FInstance)) then
    FInstance := TSlowDownManager.Create();

  if not(FInstance.GetDictionary.TryGetValue(AConfig.Id, LConfig)) then
  begin
    FInstance.GetDictionary.Add(AConfig.Id, AConfig);
    LConfig := AConfig;
  end;

  FInstance.Config := LConfig;

  Result := FInstance;
end;

class function TSlowDownManager.New(const AId: String; const ADelayAfter, ADelayMs, ATimeout: Integer): TSlowDownManager;
var
  LConfig: TSlowDownConfig;
begin
  if not(Assigned(FInstance)) then
    FInstance := TSlowDownManager.Create();

  if not(FInstance.GetDictionary.TryGetValue(AId, LConfig)) then
  begin
    LConfig.Id := AId;
    LConfig.DelayAfter := ADelayAfter;
    LConfig.DelayMs := ADelayMs;
    LConfig.MaxDelayMs := 0;
    LConfig.Timeout := ATimeout;
    LConfig.Store := nil;

    FInstance.GetDictionary.Add(AId, LConfig);
  end;

  FInstance.Config := LConfig;

  Result := FInstance;
end;

procedure TSlowDownManager.Save;
begin
  GetDictionary.Remove(Config.Id);
  GetDictionary.Add(Config.Id, Config);
end;

class procedure TSlowDownManager.FinalizeInstance;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

function TSlowDownManager.GetDictionary: TMemoryDictionary<TSlowDownConfig>;
begin
  Result := FDictionary;
end;

end.
