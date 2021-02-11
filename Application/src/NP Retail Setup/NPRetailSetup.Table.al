table 6150613 "NPR NP Retail Setup"
{

    Caption = 'NP Retail Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
            ObsoleteState = Removed;
            ObsoleteReason = 'This field won''t be used anymore.';
            ObsoleteTag = 'Moved to POS Posting Profile';
        }
        field(150; "Sale Fiscal No. Series"; Code[10])
        {
            Caption = 'Sale Fiscal No. Series';
            DataClassification = CustomerContent;
            Description = 'NPR5.39';
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                NoSeries: Record "No. Series";
            begin
                if "Sale Fiscal No. Series" <> '' then begin
                    NoSeries.Get("Sale Fiscal No. Series");
                    NoSeries.TestField("Default Nos.", true);
                end;
            end;
        }
        field(151; "Balancing Fiscal No. Series"; Code[10])
        {
            Caption = 'Balancing Fiscal No. Series';
            DataClassification = CustomerContent;
            Description = 'NPR5.40';
            TableRelation = "No. Series";
        }
        field(160; "Fill Sale Fiscal No. On"; Option)
        {
            Caption = 'Fill Sale Fiscal No. On';
            DataClassification = CustomerContent;
            Description = 'NPR5.40';
            OptionCaption = 'All Sales,Successful Sales';
            OptionMembers = All,Successful;
        }
        field(200; "Allow Zero Amount Sales"; Boolean)
        {
            Caption = 'Allow Zero Amount Sales';
            DataClassification = CustomerContent;
            Description = 'NPR5.42 [312104]';
        }
        field(210; "Default POS Posting Profile"; Code[20])
        {
            Caption = 'Default POS Posting Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            TableRelation = "NPR POS Posting Profile";
            ObsoleteState = Removed;
            ObsoleteReason = 'This field won''t be used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(231; "Standard Conditions"; Text[250])
        {
            Caption = 'Standard Conditions';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            ObsoleteState = Removed;
            ObsoleteReason = 'This field is not being used anymore';
            ObsoleteTag = 'Refactoring 3/2/2021';
        }
        field(232; Privacy; Text[250])
        {
            Caption = 'Privacy';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            ObsoleteState = Removed;
            ObsoleteReason = 'This field is not being used anymore';
            ObsoleteTag = 'Refactoring 3/2/2021';
        }
        field(233; "License Agreement"; Text[250])
        {
            Caption = 'License Agreement';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            ObsoleteState = Removed;
            ObsoleteReason = 'This field is not being used anymore';
            ObsoleteTag = 'Refactoring 3/2/2021';
        }

        field(10000; "Data Model Build"; Integer)
        {
            Caption = 'Data Model Build';
            DataClassification = CustomerContent;
        }
        field(10001; "Last Data Model Build Upgrade"; DateTime)
        {
            Caption = 'Last Data Model Build Upgrade';
            DataClassification = CustomerContent;
        }
        field(10002; "Last Data Model Build User ID"; Code[50])
        {
            Caption = 'Last Data Model Build User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;
            ObsoleteState = Removed;
            ObsoleteReason = 'This field is not being used anymore';
            ObsoleteTag = 'Refactoring 3/2/2021';
        }
        field(10003; "Prev. Data Model Build"; Integer)
        {
            Caption = 'Prev. Data Model Build';
            DataClassification = CustomerContent;
        }
        field(10010; "Advanced POS Entries Activated"; Boolean)
        {
            Caption = 'Advanced POS Entries Activated';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
            ObsoleteState = Removed;
            ObsoleteReason = 'This field won''t be used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(10020; "Advanced Posting Activated"; Boolean)
        {
            Caption = 'Advanced Posting Activated';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            ObsoleteState = Removed;
            ObsoleteReason = 'This field won''t be used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(20000; "Environment Database Name"; Text[250])
        {
            Caption = 'Environment Database Name';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(20001; "Environment Company Name"; Text[250])
        {
            Caption = 'Environment Company Name';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(20002; "Environment Tenant Name"; Text[250])
        {
            Caption = 'Environment Tenant Name';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(20003; "Environment Type"; Option)
        {
            Caption = 'Environment Type';
            DataClassification = CustomerContent;
            OptionCaption = 'PROD,DEMO,TEST,DEV';
            OptionMembers = PROD,DEMO,TEST,DEV;
            ObsoleteState = Removed;
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(20004; "Environment Verified"; Boolean)
        {
            Caption = 'Environment Verified';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(20005; "Environment Template"; Boolean)
        {
            Caption = 'Environment Template';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(30000; "Enable Client Diagnostics"; Boolean)
        {
            Caption = 'Enable Client Diagnostics';
            DataClassification = CustomerContent;
            Description = 'NPR5.38,NPR5.40';
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure GetPublisherCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Sales Price Calc. Mgt.");
    end;

    local procedure GetPublisherFunction(): Text
    begin
        exit('OnFindItemPrice');
    end;
}

