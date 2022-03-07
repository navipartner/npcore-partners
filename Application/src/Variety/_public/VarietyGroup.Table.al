table 6059976 "NPR Variety Group"
{
    // NPR4.14/JDH/20150724 CASE 201022 Lookup page added
    // NPR4.16/JDH/20151022 CASE 225661 Changed NotBlank to yes, to avoid blank primary key value
    // VRT1.10/JDH/20151202 CASE 201022 Lock table set to false when creating a copy of existing table
    // VRT1.11/JDH /20160602 CASE 242940 Added Captions
    // NPR5.32/JDH /20170510 CASE 274170 Changed No Series to code 10
    // NPR5.43/JDH /20180628 CASE 317108 Added setup fields for Generation of Variant Codes
    // NPR5.47/NPKNAV/20181026  CASE 327541-01 Transport NPR5.47 - 26 October 2018
    // NPR5.49/BHR /20190218 CASE 341465 Increase size of Variety Tables from code 20 to code 40

    Caption = 'Variety Group';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Variety Group";
    LookupPageID = "NPR Variety Group";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                TestField("Copy Naming Variety 1", "Copy Naming Variety 1"::TableCodeAndNoSeries);
            end;
        }
        field(20; "Variety 1"; Code[10])
        {
            Caption = 'Variety 1';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(21; "Variety 1 Table"; Code[40])
        {
            Caption = 'Variety 1 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 1"));
        }
        field(22; "Create Copy of Variety 1 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 1 Table';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not "Create Copy of Variety 1 Table" then
                    "Copy Naming Variety 1" := 0;
            end;
        }
        field(23; "Copy Naming Variety 1"; Option)
        {
            Caption = 'Copy Naming Variety 1';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Table Code + Item No.,Table Code +  No. Series';
            OptionMembers = " ",TableCodeAndItemNo,TableCodeAndNoSeries;

            trigger OnValidate()
            begin
                if "Copy Naming Variety 1" <> "Copy Naming Variety 1"::" " then
                    TestField("Create Copy of Variety 1 Table");
            end;
        }
        field(30; "Variety 2"; Code[10])
        {
            Caption = 'Variety 2';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(31; "Variety 2 Table"; Code[40])
        {
            Caption = 'Variety 2 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 2"));
        }
        field(32; "Create Copy of Variety 2 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 2 Table';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not "Create Copy of Variety 2 Table" then
                    "Copy Naming Variety 2" := 0;
            end;
        }
        field(33; "Copy Naming Variety 2"; Option)
        {
            Caption = 'Copy Naming Variety 2';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Table Code + Item No.,Table Code +  No. Series';
            OptionMembers = " ",TableCodeAndItemNo,TableCodeAndNoSeries;

            trigger OnValidate()
            begin
                if "Copy Naming Variety 2" <> "Copy Naming Variety 2"::" " then
                    TestField("Create Copy of Variety 2 Table");
            end;
        }
        field(40; "Variety 3"; Code[10])
        {
            Caption = 'Variety 3';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(41; "Variety 3 Table"; Code[40])
        {
            Caption = 'Variety 3 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 3"));
        }
        field(42; "Create Copy of Variety 3 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 3 Table';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not "Create Copy of Variety 3 Table" then
                    "Copy Naming Variety 3" := 0;
            end;
        }
        field(43; "Copy Naming Variety 3"; Option)
        {
            Caption = 'Copy Naming Variety 3';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Table Code + Item No.,Table Code +  No. Series';
            OptionMembers = " ",TableCodeAndItemNo,TableCodeAndNoSeries;

            trigger OnValidate()
            begin
                if "Copy Naming Variety 3" <> "Copy Naming Variety 3"::" " then
                    TestField("Create Copy of Variety 3 Table");
            end;
        }
        field(50; "Variety 4"; Code[10])
        {
            Caption = 'Variety 4';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(51; "Variety 4 Table"; Code[40])
        {
            Caption = 'Variety 4 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 4"));
        }
        field(52; "Create Copy of Variety 4 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 4 Table';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not "Create Copy of Variety 4 Table" then
                    "Copy Naming Variety 4" := 0;
            end;
        }
        field(53; "Copy Naming Variety 4"; Option)
        {
            Caption = 'Copy Naming Variety 4';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Table Code + Item No.,Table Code +  No. Series';
            OptionMembers = " ",TableCodeAndItemNo,TableCodeAndNoSeries;

            trigger OnValidate()
            begin
                if "Copy Naming Variety 4" <> "Copy Naming Variety 4"::" " then
                    TestField("Create Copy of Variety 4 Table");
            end;
        }
        field(60; "Cross Variety No."; Option)
        {
            Caption = 'Cross Variety No.';
            DataClassification = CustomerContent;
            OptionCaption = 'Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = Variety1,Variety2,Variety3,Variety4;
        }
        field(100; "Variant Code Part 1"; Option)
        {
            Caption = 'Variant Code Part 1';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Variety1Value,Variety2Value,Variety3Value,Variety4Value,NoSeries';
            OptionMembers = " ",Variety1Value,Variety2Value,Variety3Value,Variety4Value,NoSeries;

            trigger OnValidate()
            begin
                //-NPR5.43 [317108]
                CheckVarietySetup("Variant Code Part 1");
                //+NPR5.43 [317108]
            end;
        }
        field(101; "Variant Code Part 1 Length"; Option)
        {
            Caption = 'Variant Code Part 1 Length';
            DataClassification = CustomerContent;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,Max';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","Max";

            trigger OnValidate()
            begin
                //-NPR5.43 [317108]
                CheckMaxLength();
                //+NPR5.43 [317108]
            end;
        }
        field(105; "Variant Code Seperator 1"; Text[1])
        {
            Caption = 'Variant Code Seperator 1';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.43 [317108]
                CheckMaxLength();
                ChekIllegalCharacter("Variant Code Seperator 1");
                //+NPR5.43 [317108]
            end;
        }
        field(110; "Variant Code Part 2"; Option)
        {
            Caption = 'Variant Code Part 2';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Variety1Value,Variety2Value,Variety3Value,Variety4Value,NoSeries';
            OptionMembers = " ",Variety1Value,Variety2Value,Variety3Value,Variety4Value,NoSeries;

            trigger OnValidate()
            begin
                //-NPR5.43 [317108]
                CheckVarietySetup("Variant Code Part 2");
                //+NPR5.43 [317108]
            end;
        }
        field(111; "Variant Code Part 2 Length"; Option)
        {
            Caption = 'Variant Code Part 2 Length';
            DataClassification = CustomerContent;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,Max';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","Max";

            trigger OnValidate()
            begin
                //-NPR5.43 [317108]
                CheckMaxLength();
                //+NPR5.43 [317108]
            end;
        }
        field(115; "Variant Code Seperator 2"; Text[1])
        {
            Caption = 'Variant Code Seperator 2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.43 [317108]
                CheckMaxLength();
                ChekIllegalCharacter("Variant Code Seperator 2");
                //+NPR5.43 [317108]
            end;
        }
        field(120; "Variant Code Part 3"; Option)
        {
            Caption = 'Variant Code Part 3';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Variety1Value,Variety2Value,Variety3Value,Variety4Value,NoSeries';
            OptionMembers = " ",Variety1Value,Variety2Value,Variety3Value,Variety4Value,NoSeries;

            trigger OnValidate()
            begin
                //-NPR5.43 [317108]
                CheckVarietySetup("Variant Code Part 3");
                //+NPR5.43 [317108]
            end;
        }
        field(121; "Variant Code Part 3 Length"; Option)
        {
            Caption = 'Variant Code Part 3 Length';
            DataClassification = CustomerContent;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,Max';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","Max";

            trigger OnValidate()
            begin
                //-NPR5.43 [317108]
                CheckMaxLength();
                //+NPR5.43 [317108]
            end;
        }

        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }

        key(Key2; "Replication Counter")
        {

        }
    }

    fieldgroups
    {
    }

    var
        NextNoSeriesCode: Code[20];
        MaxLengthExceeded: Label 'The Maximum length of the Variety combinations has been exceeded. A Variant Code ca only be 10 characters long';
        IllegalCharacter: Label 'The character %1 is not allowed to use as a seperator';

    internal procedure GetVariety1Table(Item: Record Item): Code[40]
    begin
        if not "Create Copy of Variety 1 Table" then
            exit("Variety 1 Table");

        TestField("Copy Naming Variety 1");
        if "Copy Naming Variety 1" = "Copy Naming Variety 1"::TableCodeAndItemNo then
            exit(CopyStr("Variety 1 Table" + '-' + Item."No.", 1, 40));

        TestField("No. Series");

        exit(CopyStr("Variety 1 Table" + '-' + GetNextNo(), 1, 40));
    end;

    internal procedure GetVariety2Table(Item: Record Item): Code[40]
    begin
        if not "Create Copy of Variety 2 Table" then
            exit("Variety 2 Table");

        TestField("Copy Naming Variety 2");
        if "Copy Naming Variety 2" = "Copy Naming Variety 2"::TableCodeAndItemNo then
            exit(CopyStr("Variety 2 Table" + '-' + Item."No.", 1, 40));

        TestField("No. Series");

        exit(CopyStr("Variety 2 Table" + '-' + GetNextNo(), 1, 40));
    end;

    internal procedure GetVariety3Table(Item: Record Item): Code[40]
    begin
        if not "Create Copy of Variety 3 Table" then
            exit("Variety 3 Table");

        TestField("Copy Naming Variety 3");
        if "Copy Naming Variety 3" = "Copy Naming Variety 3"::TableCodeAndItemNo then
            exit(CopyStr("Variety 3 Table" + '-' + Item."No.", 1, 40));

        TestField("No. Series");

        exit(CopyStr("Variety 3 Table" + '-' + GetNextNo(), 1, 40));
    end;

    Internal procedure GetVariety4Table(Item: Record Item): Code[40]
    begin
        if not "Create Copy of Variety 4 Table" then
            exit("Variety 4 Table");

        TestField("Copy Naming Variety 4");
        if "Copy Naming Variety 4" = "Copy Naming Variety 4"::TableCodeAndItemNo then
            exit(CopyStr("Variety 4 Table" + '-' + Item."No.", 1, 40));

        TestField("No. Series");

        exit(CopyStr("Variety 4 Table" + '-' + GetNextNo(), 1, 40));
    end;

    internal procedure GetNextNo(): Code[20]
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if NextNoSeriesCode <> NextNoSeriesCode then
            exit(NextNoSeriesCode);

        TestField("No. Series");
        NextNoSeriesCode := NoSeriesMgt.GetNextNo("No. Series", Today, true);
    end;

    internal procedure CopyTableData(Item: Record Item)
    begin
        if "Create Copy of Variety 1 Table" then
            CopyTable2NewTable("Variety 1", "Variety 1 Table", Item."NPR Variety 1 Table");
        if "Create Copy of Variety 2 Table" then
            CopyTable2NewTable("Variety 2", "Variety 2 Table", Item."NPR Variety 2 Table");
        if "Create Copy of Variety 3 Table" then
            CopyTable2NewTable("Variety 3", "Variety 3 Table", Item."NPR Variety 3 Table");
        if "Create Copy of Variety 4 Table" then
            CopyTable2NewTable("Variety 4", "Variety 4 Table", Item."NPR Variety 4 Table");
    end;

    internal procedure CopyTable2NewTable(Type: Code[10]; FromTable: Code[40]; ToTable: Code[40])
    var
        FromVRTTable: Record "NPR Variety Table";
        ToVRTTable: Record "NPR Variety Table";
        FromVRTValue: Record "NPR Variety Value";
        ToVRTValue: Record "NPR Variety Value";
    begin
        FromVRTTable.Get(Type, FromTable);
        ToVRTTable.TransferFields(FromVRTTable, true);
        //ToVRTTable.Type := Type;
        ToVRTTable.Code := ToTable;
        ToVRTTable."Is Copy" := true;
        ToVRTTable."Copy from" := FromTable;
        //-VRT1.10
        ToVRTTable."Lock Table" := false;
        //+VRT1.10
        ToVRTTable.Insert();

        FromVRTValue.SetRange(Type, Type);
        FromVRTValue.SetRange(Table, FromTable);
        if FromVRTValue.FindSet() then
            repeat
                ToVRTValue.TransferFields(FromVRTValue, true);
                ToVRTValue.Table := ToTable;
                ToVRTValue.Insert();
            until FromVRTValue.Next() = 0;
    end;

    local procedure CheckMaxLength()
    var
        Length: Integer;
    begin
        //-NPR5.43 [317108]
        if "Variant Code Part 1 Length" < "Variant Code Part 1 Length"::Max then
            Length := "Variant Code Part 1 Length";
        if "Variant Code Part 2 Length" < "Variant Code Part 2 Length"::Max then
            Length += "Variant Code Part 2 Length";
        if "Variant Code Part 3 Length" < "Variant Code Part 3 Length"::Max then
            Length += "Variant Code Part 3 Length";
        Length += StrLen("Variant Code Seperator 1");
        Length += StrLen("Variant Code Seperator 2");
        if Length > 10 then
            Error(MaxLengthExceeded);
        //+NPR5.43 [317108]
    end;

    local procedure CheckVarietySetup(VarietyNo: Integer)
    begin
        //-NPR5.43 [317108]
        case VarietyNo of
            1:
                begin
                    TestField("Variety 1");
                    TestField("Variety 1 Table");
                end;
            2:
                begin
                    TestField("Variety 2");
                    TestField("Variety 2 Table");
                end;
            3:
                begin
                    TestField("Variety 3");
                    TestField("Variety 3 Table");
                end;
            4:
                begin
                    TestField("Variety 4");
                    TestField("Variety 4 Table");
                end;
        end;
        //+NPR5.43 [317108]
    end;

    local procedure ChekIllegalCharacter(Character: Text)
    begin
        //-NPR5.43 [317108]
        if Character in ['%', '&', '|', '*', '?'] then
            Error(IllegalCharacter, Character);
        //+NPR5.43 [317108]
    end;

    internal procedure GetVariantCodeExample(): Code[50]
    var
        Var1Value: Code[50];
        Var2Value: Code[50];
        Var3Value: Code[50];
    begin
        //-NPR5.43 [317108]
        Var1Value := GetVariantValue("Variant Code Part 1");
        Var2Value := GetVariantValue("Variant Code Part 2");
        Var3Value := GetVariantValue("Variant Code Part 3");
        exit(FormatValues(Var1Value, "Variant Code Seperator 1", Var2Value, "Variant Code Seperator 2", Var3Value));
        //+NPR5.43 [317108]
    end;

    local procedure GetVariantValue(SelectedOption: Option " ",Variety1Value,Variety2Value,Variety3Value,Variety4Value,NoSeries): Code[50]
    var
        VarietyValue: Record "NPR Variety Value";
    begin
        //-NPR5.43 [317108]
        if SelectedOption in [SelectedOption::" ", SelectedOption::NoSeries] then
            exit;

        case SelectedOption of
            SelectedOption::Variety1Value:
                begin
                    VarietyValue.SetRange(Type, "Variety 1");
                    VarietyValue.SetRange(Table, "Variety 1 Table");
                end;
            SelectedOption::Variety2Value:
                begin
                    VarietyValue.SetRange(Type, "Variety 2");
                    VarietyValue.SetRange(Table, "Variety 2 Table");
                end;
            SelectedOption::Variety3Value:
                begin
                    VarietyValue.SetRange(Type, "Variety 3");
                    VarietyValue.SetRange(Table, "Variety 3 Table");
                end;
            SelectedOption::Variety4Value:
                begin
                    VarietyValue.SetRange(Type, "Variety 4");
                    VarietyValue.SetRange(Table, "Variety 4 Table");
                end;
        end;
        if VarietyValue.FindFirst() then
            exit(VarietyValue.Value);
        exit('<>');
        //+NPR5.43 [317108]
    end;

    local procedure FormatValues(Value1: Code[50]; Sep1: Text; Value2: Code[50]; Sep2: Text; Value3: Code[50]): Code[50]
    var
        NewVar1Code: Code[50];
        NewVar2Code: Code[50];
        NewVar3Code: Code[50];
        CurrentLength: Integer;
    begin
        //-NPR5.43 [317108]
        if "Variant Code Part 1 Length" > 1 then
            NewVar1Code := CopyStr(CopyStr(Value1, 1, "Variant Code Part 1 Length"), 1, MaxStrLen(NewVar1Code));
        if "Variant Code Part 2 Length" > 1 then
            NewVar2Code := CopyStr(CopyStr(Value2, 1, "Variant Code Part 2 Length"), 1, MaxStrLen(NewVar2Code));
        if "Variant Code Part 3 Length" > 1 then
            NewVar3Code := CopyStr(CopyStr(Value3, 1, "Variant Code Part 3 Length"), 1, MaxStrLen(NewVar3Code));

        CurrentLength := StrLen(NewVar1Code) + StrLen(NewVar2Code) + StrLen(NewVar3Code) + StrLen("Variant Code Seperator 1") + StrLen("Variant Code Seperator 2");
        if CurrentLength > 10 then
            Error(MaxLengthExceeded);

        case true of
            ((NewVar1Code = '') and (NewVar2Code = '') and (NewVar3Code = '')):
                exit('');
            ((NewVar1Code = '') and (NewVar2Code = '')):
                exit(NewVar3Code);
            ((NewVar1Code = '') and (NewVar3Code = '')):
                exit(NewVar2Code);
            ((NewVar2Code = '') and (NewVar3Code = '')):
                exit(NewVar1Code);
            (NewVar1Code = ''):
                exit(NewVar2Code + Sep2 + NewVar3Code);
            (NewVar2Code = ''):
                exit(NewVar1Code + Sep1 + NewVar3Code);
            (NewVar3Code = ''):
                exit(NewVar1Code + Sep1 + NewVar2Code);
        end;
        //+NPR5.43 [317108]
    end;
}
