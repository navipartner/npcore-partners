codeunit 6014596 "Generic Page Web Serv. Client"
{

    trigger OnRun()
    begin
    end;

    var
        Assembly: DotNet Assembly;
        ServiceType: DotNet Type;
        EntityType: DotNet Type;
        FilterType: DotNet Type;
        FieldsType: DotNet Type;
        LineType: DotNet Type;
        Entity: DotNet Object;
        Line: DotNet Object;
        Entities: DotNet Array;
        Filters: DotNet List_Of_T;
        Lines: DotNet List_Of_T;
        LinesProperty: DotNet PropertyInfo;
        Activator: DotNet Activator;
        _Read: DotNet MethodInfo;
        _ReadByRecId: DotNet MethodInfo;
        _ReadMultiple: DotNet MethodInfo;
        _IsUpdated: DotNet MethodInfo;
        _GetRecIdFromKey: DotNet MethodInfo;
        _Create: DotNet MethodInfo;
        _CreateMultiple: DotNet MethodInfo;
        _Update: DotNet MethodInfo;
        _UpdateMultiple: DotNet MethodInfo;
        _Delete: DotNet MethodInfo;
        Text001: Label '%1 is not allowed for the %2 web service.';
        ServiceUri: Text;
        Name: Text;
        Text002: Label '%1 is not initialized.';
        Text003: Label '%1 does not have a definition for the %2 field.';
        AssertAllowedOperationName: Text;
        GetNull: Boolean;
        Text004: Label 'The service is not a Microsoft Dynamics NAV page service.\\%1';
        Cursor: Integer;
        Text005: Label 'Field %1 does not exist for the %2 web service.';
        Text006: Label '%1 does not have lines.';
        Text007: Label 'Line';
        Text008: Label 'Unhandled type: %1.';
        UserName: Text;
        Password: Text;
        UseDefaultCredentials: Boolean;
        Text009: Label 'Option %1 for field %2 is not available.';

    procedure CONNECT(Uri: Text)
    var
        WebRequest: DotNet WebRequest;
        RequestStream: DotNet Stream;
        ServiceDescription: DotNet ServiceDescription;
        ServiceDescriptionImporter: DotNet ServiceDescriptionImporter;
        ServiceDescriptionImportWarnings: DotNet ServiceDescriptionImportWarnings;
        CodeNamespace: DotNet CodeNamespace;
        CodeCompileUnit: DotNet CodeCompileUnit;
        CodeCompileUnitArray: DotNet Array;
        CodeGenerationOptions: DotNet CodeGeneratorOptions;
        CompilerParameters: DotNet CompilerParameters;
        CompilerResults: DotNet CompilerResults;
        StringWriter: DotNet StringWriter;
        CultureInfo: DotNet CultureInfo;
        CSharpCodeProvider: DotNet CSharpCodeProvider;
        AssemblyReferences: DotNet Array;
        String: DotNet String;
    begin
        ServiceUri := Uri;

        WebRequest := WebRequest.Create(ServiceUri);
        Authenticate(WebRequest);
        RequestStream := WebRequest.GetResponse().GetResponseStream();

        ServiceDescription := ServiceDescription.Read(RequestStream);
        ServiceDescriptionImporter := ServiceDescriptionImporter.ServiceDescriptionImporter();
        ServiceDescriptionImporter.AddServiceDescription(ServiceDescription,'','');
        ServiceDescriptionImporter.ProtocolName := 'SOAP';
        ServiceDescriptionImporter.CodeGenerationOptions := 1; // GenerateProperties

        CodeNamespace := CodeNamespace.CodeNamespace();
        CodeCompileUnit := CodeCompileUnit.CodeCompileUnit();
        CodeCompileUnit.Namespaces.Add(CodeNamespace);

        ServiceDescriptionImportWarnings := ServiceDescriptionImporter.Import(CodeNamespace, CodeCompileUnit);
        if ServiceDescriptionImportWarnings = 0 then begin
          StringWriter := StringWriter.StringWriter(CultureInfo.CurrentCulture);
          CSharpCodeProvider := CSharpCodeProvider.CSharpCodeProvider();
          CSharpCodeProvider.GenerateCodeFromNamespace(CodeNamespace,StringWriter,CodeGenerationOptions.CodeGeneratorOptions);

          AssemblyReferences := AssemblyReferences.CreateInstance(GetDotNetType(String),2);
          AssemblyReferences.SetValue('System.Web.Services.dll',0);
          AssemblyReferences.SetValue('System.Xml.dll',1);

          CompilerParameters := CompilerParameters.CompilerParameters(AssemblyReferences);
          CompilerParameters.GenerateExecutable := false;
          CompilerParameters.GenerateInMemory := true;
          CompilerParameters.TreatWarningsAsErrors := true;
          CompilerParameters.WarningLevel := 4;

          CodeCompileUnitArray := CodeCompileUnitArray.CreateInstance(GetDotNetType(CodeCompileUnit),1);
          CodeCompileUnitArray.SetValue(CodeCompileUnit,0);

          CompilerResults := CSharpCodeProvider.CompileAssemblyFromDom(CompilerParameters,CodeCompileUnitArray);
          Assembly := CompilerResults.CompiledAssembly;

          DetectTypes(ServiceDescription.Services.Item(0).Name);

          RESET;
        end;
    end;

    local procedure DetectTypes(ServiceName: Text)
    var
        Types: DotNet Array;
        Type: DotNet Type;
        TypeName: DotNet String;
        PropertyInfo: DotNet PropertyInfo;
        Properties: DotNet Array;
        IsPageService: Boolean;
        i: Integer;
    begin
        Clear(LineType);
        Clear(ServiceType);
        Clear(FilterType);
        Clear(FieldsType);
        Clear(LinesProperty);

        Types := Assembly.ExportedTypes;
        if Types.Length > 1 then begin
          for i := 0 to Types.Length - 1 do begin
            Type := Types.GetValue(i);
            TypeName := Type.Name;
            case true of
              TypeName.EndsWith('_Line'):     LineType := Type;
              TypeName.EndsWith('_Service'):  ServiceType := Type;
              TypeName.EndsWith('_Filter'):   FilterType := Type;
              TypeName.EndsWith('_Fields'):   FieldsType := Type;
            end;
          end;

          if not IsNull(ServiceType) then begin
            TypeName := ServiceType.Name;
            Name := TypeName.Substring(0,TypeName.Length - 8);
            EntityType := Assembly.GetType(Name);

            if HASLINES then begin
              Properties := EntityType.GetProperties;
              for i := 0 to Properties.Length - 1 do begin
                PropertyInfo := Properties.GetValue(i);
                Type := PropertyInfo.PropertyType;
                if Type.Name = LineType.Name + '[]' then
                  LinesProperty := PropertyInfo;
              end;
            end;

            _Read := ServiceType.GetMethod('Read');
            _ReadByRecId := ServiceType.GetMethod('ReadByRecId');
            _ReadMultiple := ServiceType.GetMethod('ReadMultiple');
            _IsUpdated := ServiceType.GetMethod('IsUpdated');
            _GetRecIdFromKey := ServiceType.GetMethod('GetRecIdFromKey');
            _Create := ServiceType.GetMethod('Create');
            _CreateMultiple := ServiceType.GetMethod('CreateMultiple');
            _Update := ServiceType.GetMethod('Update');
            _UpdateMultiple := ServiceType.GetMethod('UpdateMultiple');
            _Delete := ServiceType.GetMethod('Delete');
            if not (IsNull(_Read) and IsNull(_ReadMultiple) and IsNull(_IsUpdated)) then
              IsPageService := true;
          end;
        end;

        if not IsPageService then
          Error(Text004,ServiceUri);
    end;

    procedure HASLINES(): Boolean
    begin
        exit(not IsNull(LineType));
    end;

    procedure INSERTALLOWED(): Boolean
    begin
        AssertAllowedOperationName := 'Insert';
        exit(not IsNull(_Create));
    end;

    procedure MODIFYALLOWED(): Boolean
    begin
        AssertAllowedOperationName := 'Modify';
        exit(not IsNull(_Update));
    end;

    procedure DELETEALLOWED(): Boolean
    begin
        AssertAllowedOperationName := 'Delete';
        exit(not IsNull(_Delete));
    end;

    local procedure AssertAllowed(Allowed: Boolean)
    begin
        if not Allowed then
          Error(Text001,AssertAllowedOperationName,Name);
    end;

    local procedure AssertInitialized()
    begin
        if IsNull(Entity) then
          Error(Text002,Name);
    end;

    local procedure AssertHasLines()
    begin
        if not HASLINES then
          Error(Text006,Name);
    end;

    local procedure AssertLineInitialized()
    begin
        if IsNull(Line) then
          Error(Text002,Text007);
    end;

    procedure INIT()
    var
        String: DotNet String;
    begin
        Entity := Activator.CreateInstance(EntityType);
        Lines := Lines.List;
        Clear(Entities);
        RESET;
    end;

    procedure NEWLINE()
    var
        LinesArray: DotNet Array;
        i: Integer;
    begin
        AssertHasLines;
        Line := Activator.CreateInstance(LineType);
        Lines.Add(Line);

        LinesArray := LinesArray.CreateInstance(LineType,Lines.Count);
        for i := 0 to Lines.Count - 1 do
          LinesArray.SetValue(Lines.Item(i),i);

        LinesProperty.SetValue(Entity,LinesArray);
    end;

    procedure CREATE()
    var
        Service: DotNet Object;
        "Object": DotNet Object;
        Parameters: DotNet Array;
    begin
        AssertAllowed(INSERTALLOWED);
        AssertInitialized;

        Parameters := Parameters.CreateInstance(GetDotNetType(Object),_Create.GetParameters().Length);
        Parameters.SetValue(Entity,Parameters.Length - 1);

        Service := Activator.CreateInstance(ServiceType);
        Authenticate(Service);

        _Create.Invoke(Service,Parameters);
        Entity := Parameters.GetValue(Parameters.Length - 1);
    end;

    procedure UPDATE()
    var
        Service: DotNet Object;
        "Object": DotNet Object;
        Parameters: DotNet Array;
    begin
        AssertAllowed(MODIFYALLOWED);
        AssertInitialized;

        Parameters := Parameters.CreateInstance(GetDotNetType(Object),_Update.GetParameters().Length);
        Parameters.SetValue(Entity,Parameters.Length - 1);

        Service := Activator.CreateInstance(ServiceType);
        Authenticate(Service);

        _Update.Invoke(Service,Parameters);
        Entity := Parameters.GetValue(Parameters.Length - 1);
    end;

    procedure UPDATEMULTIPLE()
    var
        Service: DotNet Object;
        "Object": DotNet Object;
        Parameters: DotNet Array;
        i: Integer;
    begin
        //this is not finished yet so don't use it
        Error('UPDATEMULTIPLE is not supported yet.');
        AssertAllowed(MODIFYALLOWED);
        AssertInitialized;

        Parameters := Parameters.CreateInstance(GetDotNetType(Object),_UpdateMultiple.GetParameters().Length);
        //Parameters.SetValue(Entity,Parameters.Length - 1);
        Parameters.SetValue(Entities,Parameters.Length - 1);

        Service := Activator.CreateInstance(ServiceType);
        Authenticate(Service);

        //_Update.Invoke(Service,Parameters);
        Entities := _UpdateMultiple.Invoke(Service,Parameters);
        //Entity := Parameters.GetValue(Parameters.Length - 1);
    end;

    procedure DELETE()
    var
        Service: DotNet Object;
        "Object": DotNet Object;
        Parameters: DotNet Array;
        "Key": Text;
    begin
        AssertAllowed(DELETEALLOWED);
        AssertInitialized;

        Key := GETVALUE('Key');
        if (Key = '') and GetNull then
          READ;

        Parameters := Parameters.CreateInstance(GetDotNetType(Object),1);
        Parameters.SetValue(GETVALUE('Key'),0);

        Service := Activator.CreateInstance(ServiceType);
        Authenticate(Service);

        _Delete.Invoke(Service,Parameters);
    end;

    procedure READ(): Boolean
    var
        Service: DotNet Object;
        "Object": DotNet Object;
        Parameters: DotNet Array;
        ParameterInfo: DotNet ParameterInfo;
        PropertyInfo: DotNet PropertyInfo;
        i: Integer;
    begin
        AssertInitialized;

        Parameters := Parameters.CreateInstance(GetDotNetType(Object),_Read.GetParameters().Length);
        for i := 0 to Parameters.Length - 1 do begin
          ParameterInfo := _Read.GetParameters().GetValue(i);
          PropertyInfo := EntityType.GetProperty(ParameterInfo.Name);
          if PropertyInfo.PropertyType.BaseType.FullName = 'System.Enum' then
            Parameters.SetValue(Format(PropertyInfo.GetValue(Entity)),i)
          else
            Parameters.SetValue(PropertyInfo.GetValue(Entity),i);
        end;

        Service := Activator.CreateInstance(ServiceType);
        Authenticate(Service);

        Entity := _Read.Invoke(Service,Parameters);

        ResetFieldSpecifiedFlag();

        Clear(Entities);
        exit(not IsNull(Entity));
    end;

    procedure READMULTIPLE(): Boolean
    var
        Service: DotNet Object;
        "Object": DotNet Object;
        Parameters: DotNet Array;
        ParameterInfo: DotNet ParameterInfo;
        ReadFilters: DotNet Array;
        NullString: DotNet String;
        i: Integer;
    begin
        ReadFilters := ReadFilters.CreateInstance(FilterType,Filters.Count);
        for i := 0 to Filters.Count - 1 do
          ReadFilters.SetValue(Filters.Item(i),i);

        Parameters := Parameters.CreateInstance(GetDotNetType(Object),3);
        Parameters.SetValue(ReadFilters,0);
        Parameters.SetValue(NullString,1);
        Parameters.SetValue(0,2);

        Service := Activator.CreateInstance(ServiceType);
        Authenticate(Service);

        Entities := _ReadMultiple.Invoke(Service,Parameters);
        Cursor := 0;

        if Entities.Length > 0 then begin
          Cursor := 0;
          NEXT;
          exit(true);
        end else
          exit(false);
    end;

    procedure READBYRECID(RecID: Text): Boolean
    var
        Service: DotNet Object;
        "Object": DotNet Object;
        Parameters: DotNet Array;
    begin
        AssertInitialized;

        Parameters := Parameters.CreateInstance(GetDotNetType(Object),1);
        Parameters.SetValue(RecID,0);

        Service := Activator.CreateInstance(ServiceType);
        Authenticate(Service);

        Entity := _ReadByRecId.Invoke(Service,Parameters);
        exit(not IsNull(Entity));
    end;

    procedure GETRECIDFROMKEY("Key": Text): Text
    var
        Service: DotNet Object;
        "Object": DotNet Object;
        Parameters: DotNet Array;
    begin
        AssertInitialized;

        Parameters := Parameters.CreateInstance(GetDotNetType(Object),1);
        Parameters.SetValue(Key,0);

        Service := Activator.CreateInstance(ServiceType);
        Authenticate(Service);

        exit(_GetRecIdFromKey.Invoke(Service,Parameters));
    end;

    procedure RESET()
    begin
        Filters := Filters.List;
    end;

    procedure NEXT(): Integer
    begin
        if Cursor < Entities.Length then begin
          Entity := Entities.GetValue(Cursor);
          Cursor := Cursor + 1;
          exit(1);
        end else
          exit(0);
    end;

    procedure SETFILTER(FieldName: Text;Criteria: Text)
    var
        EnumValues: DotNet Array;
        "Filter": DotNet Object;
        "Field": DotNet Object;
        Enum: DotNet Enum;
        PropertyInfo: DotNet PropertyInfo;
        i: Integer;
        FieldExists: Boolean;
    begin
        EnumValues := Enum.GetValues(FieldsType);
        while (i < EnumValues.Length) and (not FieldExists) do begin
          if Format(EnumValues.GetValue(i)) = FieldName then
            FieldExists := true;
          i := i + 1;
        end;
        if not FieldExists then
          Error(Text005,FieldName,Name);
        Field := Enum.Parse(FieldsType,FieldName);

        Filter := Activator.CreateInstance(FilterType);
        PropertyInfo := FilterType.GetProperty('Field');
        PropertyInfo.SetValue(Filter,Field);
        PropertyInfo := FilterType.GetProperty('Criteria');
        PropertyInfo.SetValue(Filter,Criteria);
        Filters.Add(Filter);
    end;

    procedure SetObjectValue("Field": Text;Value: Variant;Target: DotNet Object;"Action": Option Read,Update)
    var
        PropertyInfo: DotNet PropertyInfo;
        Enum: DotNet Enum;
        "Object": DotNet Object;
        Type: DotNet Type;
        EnumValues: DotNet Array;
        ValueBool: Boolean;
        ValueInt: Integer;
        ValueText: Text;
        ValueDecimal: Decimal;
        ValueDateTime: DateTime;
        Length: Integer;
    begin
        Type := Target.GetType();
        PropertyInfo := Type.GetProperty(Field);
        if IsNull(PropertyInfo) then
          Error(Text003,Type.Name,Field);

        if PropertyInfo.PropertyType.BaseType.FullName = 'System.Enum' then begin
          if Value.IsInteger then begin
            ValueInt := Value;
            EnumValues := Enum.GetValues(PropertyInfo.PropertyType);
            ValueText := Format(EnumValues.GetValue(ValueInt));
          end else
            ValueText := Value;
          Object := Enum.Parse(PropertyInfo.PropertyType,ValueText);
          PropertyInfo.SetValue(Target,Object);
        end else begin
          case PropertyInfo.PropertyType.FullName of
            'System.String':
              begin
                ValueText := Value;
                PropertyInfo.SetValue(Target,ValueText);
              end;
              'System.Decimal':
              begin
                ValueDecimal := Value;
                PropertyInfo.SetValue(Target,ValueDecimal);
              end;
            'System.DateTime':
              begin
                ValueDateTime := Value;
                PropertyInfo.SetValue(Target,ValueDateTime);
              end;
            'System.Int32':
              begin
                ValueInt := Value;
                PropertyInfo.SetValue(Target,ValueInt);
              end;
            'System.Boolean':
              begin
                ValueBool := Value;
                PropertyInfo.SetValue(Target,ValueBool);
              end;
            else
              Error(Text008,PropertyInfo.PropertyType.FullName);
          end;
        end;

        PropertyInfo := Type.GetProperty(Field + 'Specified');
        if not IsNull(PropertyInfo) then
          case Action of
            Action::Read: PropertyInfo.SetValue(Target,false);
            Action::Update: PropertyInfo.SetValue(Target,true);
          end;
    end;

    procedure GetObjectValue("Field": Text;Source: DotNet Object): Text
    var
        PropertyInfo: DotNet PropertyInfo;
        "Object": DotNet Object;
        Type: DotNet Type;
    begin
        GetNull := false;
        Type := Source.GetType();

        PropertyInfo := Type.GetProperty(Field);
        if IsNull(PropertyInfo) then
          Error(Text003,Type.Name,Field);

        if not IsNull(Source) then begin
          Object := PropertyInfo.GetValue(Source);
          if not IsNull(Object) then
            exit(Object.ToString());
        end;

        GetNull := true;
        exit('');
    end;

    procedure SETVALUE("Field": Text;Value: Variant;"Action": Integer)
    begin
        SetObjectValue(Field,Value,Entity,Action);
    end;

    procedure GETVALUE("Field": Text): Text
    var
        PropertyInfo: DotNet PropertyInfo;
        "Object": DotNet Object;
    begin
        exit(GetObjectValue(Field,Entity));
    end;

    procedure SETLINEVALUE("Field": Text;Value: Variant;"Action": Integer)
    begin
        SetObjectValue(Field,Value,Line,Action);
    end;

    procedure GETLINEVALUE("Field": Text): Text
    begin
        exit(GetObjectValue(Field,Line));
    end;

    local procedure Authenticate(ServiceInstance: DotNet SoapHttpClientProtocol)
    var
        Client: DotNet WebRequest;
        Credential: DotNet NetworkCredential;
    begin
        if UseDefaultCredentials then
          ServiceInstance.UseDefaultCredentials := true
        else
          ServiceInstance.Credentials := Credential.NetworkCredential(UserName,Password);
    end;

    procedure SetCredentials(UseDefaultCredentialsHere: Boolean;UserNameHere: Text;PasswordHere: Text)
    begin
        UseDefaultCredentials := UseDefaultCredentialsHere;
        UserName := UserNameHere;
        Password := PasswordHere;
    end;

    procedure GetEnumTypeValues("Field": Text;ArrayProperty: Option Length,Options,IndexValue;ValueText: Text) ReturnValue: Text
    var
        EntityLocal: DotNet Object;
        PropertyInfo: DotNet PropertyInfo;
        Enum: DotNet Enum;
        Type: DotNet Type;
        EnumValues: DotNet Array;
        i: Integer;
        FirstIndexFound: Boolean;
    begin
        EntityLocal := Activator.CreateInstance(EntityType);
        Type := EntityLocal.GetType();
        PropertyInfo := Type.GetProperty(Field);
        if IsNull(PropertyInfo) then
          Error(Text003,Type.Name,Field);

        if PropertyInfo.PropertyType.BaseType.FullName = 'System.Enum' then begin
          EnumValues := Enum.GetValues(PropertyInfo.PropertyType);
          case ArrayProperty of
            ArrayProperty::Length: ReturnValue := Format(EnumValues.Length);
            ArrayProperty::Options,ArrayProperty::IndexValue:
              for i := 0 to EnumValues.Length - 1 do begin
                if ArrayProperty = ArrayProperty::IndexValue then begin
                  if not FirstIndexFound then begin
                    FirstIndexFound := UpperCase(Format(EnumValues.GetValue(i))) = UpperCase(ValueText);
                    if FirstIndexFound then
                      ReturnValue := Format(i);
                  end;
                end else begin
                  if i = 0 then
                    ReturnValue := Format(EnumValues.GetValue(i))
                  else
                    ReturnValue := ReturnValue + ',' + Format(EnumValues.GetValue(i));
                end;
              end;
          end;
        end;
        exit(ReturnValue);
    end;

    procedure FieldExists("Field": Text): Boolean
    var
        PropertyInfo: DotNet PropertyInfo;
        "Object": DotNet Object;
        Type: DotNet Type;
    begin
        Type := Entity.GetType();
        PropertyInfo := Type.GetProperty(Field);
        exit(not IsNull(PropertyInfo));
    end;

    local procedure CheckEntityProperties(EntityHere: DotNet Object)
    var
        PropertyInfo: DotNet PropertyInfo;
        FieldPropertyInfo: DotNet PropertyInfo;
        EnumValues: DotNet Array;
        Enum: DotNet Enum;
        i: Integer;
        Value: Text;
        Type: DotNet Type;
        FieldPropertyValue: Text;
    begin
        //use this function to check field names, values and Specified property in EntityHere
        EnumValues := Enum.GetValues(FieldsType);
        for i := 0 to EnumValues.Length - 1 do begin
          Clear(FieldPropertyValue);
          PropertyInfo := EntityType.GetProperty(Format(EnumValues.GetValue(i)));
          Value := Format(PropertyInfo.GetValue(EntityHere));
          Type := EntityHere.GetType();
          FieldPropertyInfo := Type.GetProperty(PropertyInfo.Name + 'Specified');
          if not IsNull(FieldPropertyInfo) then
            FieldPropertyValue := Format(FieldPropertyInfo.GetValue(EntityHere));
        end;
    end;

    local procedure ResetFieldSpecifiedFlag()
    var
        PropertyInfo: DotNet PropertyInfo;
        FieldPropertyInfo: DotNet PropertyInfo;
        EnumValues: DotNet Array;
        Enum: DotNet Enum;
        i: Integer;
        Type: DotNet Type;
    begin
        EnumValues := Enum.GetValues(FieldsType);
        for i := 0 to EnumValues.Length - 1 do begin
          PropertyInfo := EntityType.GetProperty(Format(EnumValues.GetValue(i)));
          Type := Entity.GetType();
          FieldPropertyInfo := Type.GetProperty(PropertyInfo.Name + 'Specified');
          if not IsNull(FieldPropertyInfo) then
            FieldPropertyInfo.SetValue(Entity,false);
        end;
    end;
}

