codeunit 6150703 "POS JSON Management"
{
    // NPR5.37/MMV /20171004 CASE 289442 format dates before serializing to json to prevent timezone issue.
    // NPR5.38/VB  /20171219 CASE 255773 Enabling debugging through ToString.
    // NPR5.39/VB  /20171219 CASE 255773 Adding functionality related to WYSIWYG editor.
    // NPR5.39/VB  /20180222 CASE 255773 Fixing some issues with changing scope, as well as providing more functionality needed by WYSIWYG.
    // NPR5.40/VB  /20180222 CASE 255773 Adding HasProperty function to check for presence of a property in a JSON object.
    // NPR5.44/JDH /20180731  CASE 323499 Changed all functions to be External
    // NPR5.50/VB  /20181205  CASE 338666 Supporting Workflows 2.0


    trigger OnRun()
    begin
    end;

    var
        FrontEnd: Codeunit "POS Front End Management";
        Scope: DotNet Dictionary_Of_T_U;
        Context: DotNet Dictionary_Of_T_U;
        Text001: Label 'Property "%1" does not exist in JSON object.\\%2.';
        JObject: DotNet JObject;
        Text003: Label 'JObject parser is not initialized, and an attempt was made to parse value "%1".';
        JObjectBefore: DotNet JObject;
        JRoot: DotNet JObject;

    local procedure "---JObject Parser functions---"()
    begin
        //
        // **************************************************************
        //
        //                      JObject Parser Functions
        //
        // **************************************************************
        //
    end;

    [Scope('Personalization')]
    procedure InitializeJObjectParser(JObjectIn: DotNet JObject;FrontEndIn: Codeunit "POS Front End Management")
    begin
        JObject := JObjectIn;
        JRoot := JObject;
        FrontEndIn := FrontEnd;
    end;

    local procedure MakeSureJObjectParserIsInitialized("Key": Text)
    begin
        if IsNull(JObject) then
          FrontEnd.ReportBug(StrSubstNo(Text003,Key));
    end;

    [Scope('Personalization')]
    procedure ToString(): Text
    begin
        //-NPR5.38 [255773]
        MakeSureJObjectParserIsInitialized('');
        exit(JRoot.ToString());
        //+NPR5.38 [255773]
    end;

    [Scope('Personalization')]
    procedure GetJToken(var JToken: DotNet JToken;Property: Text;WithError: Boolean): Boolean
    var
        JTokenTemp: DotNet JToken;
    begin
        MakeSureJObjectParserIsInitialized(Property);

        //-NPR5.39 [255773]
        //JToken := JObject.Item(Property);
        //IF ISNULL(JToken) AND WithError THEN
        //  FrontEnd.ReportBug(STRSUBSTNO(Text001,Property,JObject.ToString()));
        JTokenTemp := JObject.Item(Property);
        if IsNull(JTokenTemp) then begin
          if WithError then
            FrontEnd.ReportBug(StrSubstNo(Text001,Property,JObject.ToString()));
          exit(false);
        end else
          JToken := JTokenTemp;

        exit(true);
        //+NPR5.39 [255773]
    end;

    [Scope('Personalization')]
    procedure GetJTokenPath(var JToken: DotNet JToken;Property: Text;WithError: Boolean): Boolean
    var
        JTokenTemp: DotNet JToken;
    begin
        //-NPR5.39 [255773]
        MakeSureJObjectParserIsInitialized(Property);

        JTokenTemp := JObject.SelectToken(Property);
        if IsNull(JTokenTemp) then begin
          if WithError then
            FrontEnd.ReportBug(StrSubstNo(Text001,Property,JObject.ToString()));
          exit(false);
        end else
          JToken := JTokenTemp;

        exit(true);
        //-NPR5.39 [255773]
    end;

    local procedure ObjectToVariant("Object": DotNet Object;var Variant: Variant)
    begin
        Variant := Object;
    end;

    [Scope('Personalization')]
    procedure SetScope(Name: Text;WithError: Boolean): Boolean
    begin
        MakeSureJObjectParserIsInitialized(Name);
        if Name in ['','{}','/'] then
          JObject := JRoot
        else
        //-NPR5.39 [255773]
        //  GetJToken(JObject,Name,WithError);
          if not GetJToken(JObject,Name,WithError) then
            exit(false);
        //+NPR5.39 [255773]

        exit(not IsNull(JObject));
    end;

    [Scope('Personalization')]
    procedure SetScopeRoot(WithError: Boolean): Boolean
    begin
        exit(SetScope('/',WithError));
    end;

    [Scope('Personalization')]
    procedure SetScopeParameters(WithError: Boolean): Boolean
    begin
        exit(SetScopeRoot(WithError) and SetScope('parameters',WithError));
    end;

    [Scope('Personalization')]
    procedure SetScopePath(Name: Text;WithError: Boolean): Boolean
    begin
        //-NPR5.39 [255773]
        MakeSureJObjectParserIsInitialized(Name);
        if CopyStr(Name,1,2) = '$.' then
          JObject := JRoot;
        GetJTokenPath(JObject,Name,WithError);

        exit(not IsNull(JObject));
        //+NPR5.39 [255773]
    end;

    local procedure StoreContext()
    begin
        JObjectBefore := JObject;
    end;

    local procedure RestoreContext()
    begin
        JObject := JObjectBefore;
    end;

    [Scope('Personalization')]
    procedure StoreScope() ScopeID: Guid
    begin
        //-NPR5.39 [255773]
        ScopeID := CreateGuid;
        if IsNull(Scope) then
          Scope := Scope.Dictionary;

        Scope.Add(ScopeID,JObject);
        //+NPR5.39 [255773]
    end;

    [Scope('Personalization')]
    procedure RestoreScope(ScopeID: Guid): Boolean
    begin
        //-NPR5.39 [255773]
        if IsNull(Scope) then
          exit(false);

        if not Scope.ContainsKey(ScopeID) then
          exit(false);

        JObject := Scope.Item(ScopeID);
        exit(true);
        //+NPR5.39 [255773]
    end;

    [Scope('Personalization')]
    procedure GetObject(Property: Text;var "Object": DotNet Object;WithError: Boolean): Boolean
    var
        JToken: DotNet JToken;
    begin
        Clear(Object);
        GetJToken(JToken,Property,WithError);
        if (IsNull(JToken)) then
          exit(false);

        Object := JToken.ToObject(GetDotNetType(Object));
        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetString(Property: Text;WithError: Boolean): Text
    var
        JToken: DotNet JToken;
    begin
        GetJToken(JToken,Property,WithError);

        if not IsNull(JToken) then
          exit(JToken.ToString());
    end;

    [Scope('Personalization')]
    procedure GetBoolean(Property: Text;WithError: Boolean) Bool: Boolean
    var
        String: Text;
    begin
        String := GetString(Property,WithError);
        case true of
          String = '1':
            exit(true);
          String in ['0','']:
            exit(false);
          else
            Evaluate(Bool,String);
        end;
    end;

    [Scope('Personalization')]
    procedure GetDecimal(Property: Text;WithError: Boolean) Dec: Decimal
    var
        DotNetDecimal: DotNet Decimal;
        Variant: Variant;
    begin
        if not GetObject(Property,DotNetDecimal,WithError) then
          exit;

        ObjectToVariant(DotNetDecimal,Variant);
        Dec := Variant;
    end;

    [Scope('Personalization')]
    procedure GetInteger(Property: Text;WithError: Boolean) Int: Integer
    var
        DotNetInt32: DotNet Int32;
        Variant: Variant;
    begin
        if not GetObject(Property,DotNetInt32,WithError) then
          exit;

        ObjectToVariant(DotNetInt32,Variant);
        Int := Variant;
    end;

    [Scope('Personalization')]
    procedure GetDate(Property: Text;WithError: Boolean) Date: Date
    var
        DotNetDateTime: DotNet DateTime;
    begin
        if not GetObject(Property,DotNetDateTime,WithError) then
          exit;

        Date := DT2Date(DotNetDateTime);
    end;

    [Scope('Personalization')]
    procedure GetBackEndId(Context: DotNet JObject;POSSession: Codeunit "POS Session") BackEndId: Guid
    begin
        Evaluate(BackEndId,GetString('backEndId',true));
    end;

    [Scope('Personalization')]
    procedure GetJObject(var JObjectOut: DotNet JObject)
    begin
        MakeSureJObjectParserIsInitialized('');
        JObjectOut := JObject;
    end;

    [Scope('Personalization')]
    procedure HasProperty(Property: Text): Boolean
    var
        JToken: DotNet JToken;
    begin
        //-NPR5.40
        GetJToken(JToken,Property,false);
        exit(not IsNull(JToken));
        //+NPR5.40
    end;

    [Scope('Personalization')]
    procedure GetStringParameter(ParameterName: Text;WithError: Boolean) Parameter: Text
    begin
        StoreContext();
        if not SetScopeParameters(WithError) then begin
          RestoreContext();
          exit;
        end;

        Parameter := GetString(ParameterName,WithError);

        RestoreContext();
    end;

    [Scope('Personalization')]
    procedure GetBooleanParameter(ParameterName: Text;WithError: Boolean) Parameter: Boolean
    begin
        StoreContext();
        if not SetScopeParameters(WithError) then begin
          RestoreContext();
          exit;
        end;

        Parameter := GetBoolean(ParameterName,WithError);

        RestoreContext();
    end;

    [Scope('Personalization')]
    procedure GetDecimalParameter(ParameterName: Text;WithError: Boolean) Parameter: Decimal
    begin
        StoreContext();
        if not SetScopeParameters(WithError) then begin
          RestoreContext();
          exit;
        end;

        Parameter := GetDecimal(ParameterName,WithError);

        RestoreContext();
    end;

    [Scope('Personalization')]
    procedure GetIntegerParameter(ParameterName: Text;WithError: Boolean) Parameter: Integer
    begin
        StoreContext();
        if not SetScopeParameters(WithError) then begin
          RestoreContext();
          exit;
        end;

        Parameter := GetInteger(ParameterName,WithError);

        RestoreContext();
    end;

    [Scope('Personalization')]
    procedure GetDateParameter(ParameterName: Text;WithError: Boolean) Parameter: Date
    begin
        StoreContext();
        if not SetScopeParameters(WithError) then begin
          RestoreContext();
          exit;
        end;

        Parameter := GetDate(ParameterName,WithError);

        RestoreContext();
    end;

    local procedure "---Context functions---"()
    begin
        //
        // **************************************************************
        //
        //                      Context Functions
        //
        // **************************************************************
        //
    end;

    [Scope('Personalization')]
    procedure SetContext("Key": Text;Value: Variant)
    begin
        MakeSureContextExists();
        if Context.ContainsKey(Key) then
          Context.Remove(Key);

        //-NPR5.37 [289442]
        case true of
          Value.IsDate : Context.Add(Key, Format(Value,0,9));
          else
            Context.Add(Key, Value);
        end;

        //Context.Add(Key,Value);
        //+NPR5.37 [289442]
    end;

    [Scope('Personalization')]
    procedure GetContextObject(var ContextOut: DotNet Dictionary_Of_T_U)
    begin
        MakeSureContextExists();
        ContextOut := Context;
    end;

    local procedure MakeSureContextExists()
    begin
        if IsNull(Context) then
          Context := Context.Dictionary();
    end;

    trigger JRoot::PropertyChanged(sender: Variant;e: DotNet PropertyChangedEventArgs)
    begin
    end;

    trigger JRoot::PropertyChanging(sender: Variant;e: DotNet PropertyChangingEventArgs)
    begin
    end;

    trigger JRoot::ListChanged(sender: Variant;e: DotNet ListChangedEventArgs)
    begin
    end;

    trigger JRoot::AddingNew(sender: Variant;e: DotNet AddingNewEventArgs)
    begin
    end;

    trigger JRoot::CollectionChanged(sender: Variant;e: DotNet NotifyCollectionChangedEventArgs)
    begin
    end;

    trigger JObjectBefore::PropertyChanged(sender: Variant;e: DotNet PropertyChangedEventArgs)
    begin
    end;

    trigger JObjectBefore::PropertyChanging(sender: Variant;e: DotNet PropertyChangingEventArgs)
    begin
    end;

    trigger JObjectBefore::ListChanged(sender: Variant;e: DotNet ListChangedEventArgs)
    begin
    end;

    trigger JObjectBefore::AddingNew(sender: Variant;e: DotNet AddingNewEventArgs)
    begin
    end;

    trigger JObjectBefore::CollectionChanged(sender: Variant;e: DotNet NotifyCollectionChangedEventArgs)
    begin
    end;
}

