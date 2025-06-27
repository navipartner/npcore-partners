table 6059801 "NPR HL HeyLoyalty Member"
{
    Access = Public;
    Caption = 'HeyLoyalty Member';
    DataClassification = CustomerContent;
    LookupPageId = "NPR HL HeyLoyalty Members";
    DrillDownPageId = "NPR HL HeyLoyalty Members";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Member Entry No."; Integer)
        {
            Caption = 'Member Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member"."Entry No.";
        }
        field(11; "First Name"; Text[50])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(12; "Middle Name"; Text[50])
        {
            Caption = 'Middle Name';
            DataClassification = CustomerContent;
        }
        field(13; "Last Name"; Text[50])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }
        field(14; Gender; Option)
        {
            Caption = 'Gender';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Male,Female,Other';
            OptionMembers = NOT_SPECIFIED,MALE,FEMALE,OTHER;
        }
        field(15; Birthday; Date)
        {
            Caption = 'Birthday';
            DataClassification = CustomerContent;
        }
        field(20; "E-Mail Address"; Text[80])
        {
            Caption = 'E-Mail Address';
            DataClassification = CustomerContent;
        }
        field(21; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(30; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(32; "Post Code Code"; Code[20])
        {
            Caption = 'ZIP Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            ValidateTableRelation = false;
        }
        field(33; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(34; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                CountryRegion: Record "Country/Region";
                HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
            begin
                if "Country Code" = '' then begin
                    "HL Country ID" := '';
                    exit;
                end;

                CountryRegion.Get("Country Code");
                "HL Country ID" := CopyStr(HLMappedValueMgt.GetMappedValue(CountryRegion.RecordId(), CountryRegion.FieldNo(Code), true), 1, MaxStrLen("HL Country ID"));
            end;
        }
        field(40; "Member Created Datetime"; DateTime)
        {
            Caption = 'Member Created Datetime';
            DataClassification = CustomerContent;
        }
        field(50; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership"."Entry No.";
        }
        field(51; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
            begin
                "HL Membership Name" := MemberMgt.GetMembershipHLName("Membership Code");
            end;
        }
        field(52; "HL Membership Name"; Text[100])
        {
            Caption = 'HeyLoyalty Membership Name';
            DataClassification = CustomerContent;
        }
        field(60; "E-Mail News Letter"; Option)
        {
            Caption = 'E-Mail News Letter';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Yes,No';
            OptionMembers = NOT_SPECIFIED,YES,NO;
        }
        field(80; "Last Purchased Source Id"; Text[50])
        {
            Caption = 'Last Purchased Source Id';
            DataClassification = CustomerContent;
        }
        field(90; "No. of Attributes"; Integer)
        {
            Caption = 'No. of Attributes';
            FieldClass = FlowField;
            CalcFormula = count("NPR HL Member Attribute" where("HeyLoyalty Member Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(95; Deleted; Boolean)
        {
            Caption = 'Deleted';
            DataClassification = CustomerContent;
        }
        field(96; Anonymized; Boolean)
        {
            Caption = 'Anonymized';
            DataClassification = CustomerContent;
        }
        field(99; "Created from HeyLoyalty"; Boolean)
        {
            Caption = 'Created from HeyLoyalty';
            DataClassification = CustomerContent;
        }
        field(100; "HeyLoyalty Id"; Text[50])
        {
            Caption = 'HeyLoyalty Id';
            DataClassification = CustomerContent;
        }
        field(101; "HL Member Status"; Text[30])
        {
            Caption = 'HeyLoyalty Member Status';
            DataClassification = CustomerContent;
        }
        field(102; "HL E-mail Status"; Option)
        {
            Caption = 'HeyLoyalty E-mail Status';
            DataClassification = CustomerContent;
            OptionMembers = " ",Active,"Spam Complaint","Hard Bounce";
            OptionCaption = ' ,Active,Spam Complaint,Hard Bounce';
        }
        field(103; "Unsubscribed at"; DateTime)
        {
            Caption = 'Unsubscribed at';
            DataClassification = CustomerContent;
        }
        field(104; "HL Country ID"; Code[10])
        {
            Caption = 'HeyLoyalty Country ID';
            DataClassification = CustomerContent;
        }
        field(105; "HL Country Name"; Text[50])
        {
            Caption = 'HeyLoyalty Country Name';
            DataClassification = CustomerContent;
        }
        field(110; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Store";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                NpCsStore: Record "NPR NpCs Store";
                HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
            begin
                if "Store Code" = '' then begin
                    "HL Store Name" := '';
                    exit;
                end;

                NpCsStore.Get("Store Code");
                "HL Store Name" := HLMappedValueMgt.GetMappedValue(NpCsStore.RecordId(), NpCsStore.FieldNo(Name), true);
            end;
        }
        field(115; "HL Store Name"; Text[100])
        {
            Caption = 'HeyLoyalty Store Name';
            DataClassification = CustomerContent;
        }
        field(120; "External Membership No."; Code[20])
        {
            Caption = 'External Membership No.';
            DataClassification = CustomerContent;
        }
        field(121; "Membership Issued On"; Date)
        {
            Caption = 'Membership Issued On';
            DataClassification = CustomerContent;
        }
        field(122; "Membership Valid Until"; Date)
        {
            Caption = 'Membership Valid Until Date';
            DataClassification = CustomerContent;
        }
        field(123; "Membership Item No."; Code[20])
        {
            Caption = 'Membership Item No.';
            DataClassification = CustomerContent;
        }
        field(200; "Update from HL Error"; Boolean)
        {
            Caption = 'Update from HL Error';
            DataClassification = CustomerContent;
        }
        field(201; "Last Error Message"; Blob)
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
        }
        field(300; "MultiChoice Field Filter"; Code[20])
        {
            Caption = 'MultiChoice Field Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR HL MultiChoice Field".Code;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(BCMember; "Member Entry No.") { }
        key(HLId; "HeyLoyalty Id") { }
        key(Email; "E-Mail Address") { }
        key(Phone; "Phone No.", "E-Mail Address") { }
        key(Errors; "Update from HL Error") { }
    }

    trigger OnDelete()
    var
        HLMemberAttribute: Record "NPR HL Member Attribute";
    begin
        HLMemberAttribute.SetRange("HeyLoyalty Member Entry No.", "Entry No.");
        if not HLMemberAttribute.IsEmpty() then
            HLMemberAttribute.DeleteAll();
    end;

    internal procedure FindCountryCode(): Code[10]
    var
        Country: Record "Country/Region";
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        RecRef: RecordRef;
    begin
        if "HL Country ID" = '' then
            exit('');
        if HLMappedValueMgt.FindMappedValue(Database::"Country/Region", Country.FieldNo(Code), "HL Country ID", RecRef) then begin
            RecRef.SetTable(Country);
            exit(Country.Code);
        end;

        if "HL Country Name" = '' then
            exit('');
        Country.Reset();
        Country.SetFilter(Name, '@' + "HL Country Name");
        if Country.FindFirst() then begin
            HLMappedValueMgt.SetMappedValue(Country.RecordId(), Country.FieldNo(Code), "HL Country ID", false);
            exit(Country.Code);
        end;
    end;

    internal procedure FindStoreCode(): Code[20]
    var
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        NpCsStore: Record "NPR NpCs Store";
        RecRef: RecordRef;
        StoreNotFoundErr: Label 'There is no %1 with assigned HeyLoyalty Name %2.', Comment = '%1 - "NPR NpCs Store" table caption, %2 - HeyLoyalty store name';
    begin
        if "HL Store Name" <> '' then begin
            if not HLMappedValueMgt.FindMappedValue(Database::"NPR NpCs Store", NpCsStore.FieldNo(Name), "HL Store Name", RecRef) then
                Error(StoreNotFoundErr, NpCsStore.TableCaption(), "HL Store Name");
            RecRef.SetTable(NpCsStore);
            exit(NpCsStore.Code);
        end;
        exit('');
    end;

    internal procedure SetErrorMessage(NewErrorText: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Last Error Message");
        if NewErrorText = '' then
            exit;
        "Last Error Message".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewErrorText);
    end;

    internal procedure GetErrorMessage(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        ErrorText: Text;
        NoErrorMessageTxt: Label 'No details were provided for the error.';
    begin
        if not "Update from HL Error" then
            exit('');

        ErrorText := '';
        if "Last Error Message".HasValue() then begin
            CalcFields("Last Error Message");
            "Last Error Message".CreateInStream(InStream, TextEncoding::UTF8);
            ErrorText := TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator());
        end;
        if ErrorText = '' then
            ErrorText := NoErrorMessageTxt;

        exit(ErrorText);
    end;

    internal procedure NoOfAssignedMCFieldOptions(): Integer
    var
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
    begin
        SetHLSelectedMCFOptionFilters(HLSelectedMCFOption);
        exit(HLSelectedMCFOption.Count());
    end;

    internal procedure ShowAssigneMCFOptions()
    var
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
        HLSelectMCFOptions: Page "NPR HL Select MCF Options";
    begin
        SetHLSelectedMCFOptionFilters(HLSelectedMCFOption);
        HLMultiChoiceFieldMgt.MarkAssignedMCFOptions(HLSelectedMCFOption, HLMultiChoiceFldOption);
        HLSelectedMCFOption.CopyFilter("Field Code", HLMultiChoiceFldOption."Field Code");
        HLMultiChoiceFldOption.SetCurrentKey("Field Code", "Sort Order");

        Clear(HLSelectMCFOptions);
        HLSelectMCFOptions.SetDataset(HLMultiChoiceFldOption);
        HLSelectMCFOptions.Editable(false);
        HLSelectMCFOptions.Run();
    end;

    local procedure SetHLSelectedMCFOptionFilters(var HLSelectedMCFOption: Record "NPR HL Selected MCF Option")
    begin
        HLSelectedMCFOption.SetRange("Table No.", Database::"NPR HL HeyLoyalty Member");
        HLSelectedMCFOption.SetRange("BC Record ID", Rec.RecordId);
        Rec.CopyFilter("MultiChoice Field Filter", HLSelectedMCFOption."Field Code");
    end;
}