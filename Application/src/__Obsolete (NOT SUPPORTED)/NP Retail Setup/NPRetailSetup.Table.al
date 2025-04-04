﻿table 6150613 "NPR NP Retail Setup"
{
    Access = Internal;

    Caption = 'NP Retail Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used';

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
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(150; "Sale Fiscal No. Series"; Code[20])
        {
            Caption = 'Sale Fiscal No. Series';
            DataClassification = CustomerContent;
            Description = 'NPR5.39';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(151; "Balancing Fiscal No. Series"; Code[20])
        {
            Caption = 'Balancing Fiscal No. Series';
            DataClassification = CustomerContent;
            Description = 'NPR5.40';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(160; "Fill Sale Fiscal No. On"; Option)
        {
            Caption = 'Fill Sale Fiscal No. On';
            DataClassification = CustomerContent;
            Description = 'NPR5.40';
            OptionCaption = 'All Sales,Successful Sales';
            OptionMembers = All,Successful;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(200; "Allow Zero Amount Sales"; Boolean)
        {
            Caption = 'Allow Zero Amount Sales';
            DataClassification = CustomerContent;
            Description = 'NPR5.42 [312104]';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(210; "Default POS Posting Profile"; Code[20])
        {
            Caption = 'Default POS Posting Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(231; "Standard Conditions"; Text[250])
        {
            Caption = 'Standard Conditions';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field is not being used anymore';
        }
        field(232; Privacy; Text[250])
        {
            Caption = 'Privacy';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field is not being used anymore';
        }
        field(233; "License Agreement"; Text[250])
        {
            Caption = 'License Agreement';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field is not being used anymore';
        }
        field(5058; "Open Register Password"; Code[20])
        {
            Caption = 'Open Cash Register Password';
            DataClassification = CustomerContent;
            Description = 'kode til at åbne kasseskuffen';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(5061; "Unit Cost Control"; Option)
        {
            Caption = 'Unit Cost Control';
            DataClassification = CustomerContent;
            Description = 'Spærremuligheder til ændring af á pris';
            OptionCaption = 'Enabled,Disabled,Disabled if Quantity > 0,Disabled if xUnit Cost > Unit Cost,Disabled if Quantity > 0 and xUnit Cost > Unit Cost';
            OptionMembers = Enabled,Disabled,"Disabled if Quantity > 0","Disabled if xUnit Cost > Unit Cost","Disabled if Quantity > 0 and xUnit Cost > Unit Cost";
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(5152; "Check Purchase Lines if vendor"; Boolean)
        {
            Caption = 'Check Purchase Lines If Vendor';
            DataClassification = CustomerContent;
            Description = 'Afg¢re om man på k¢bslinie skal checke om vare man taster tilh¢rer leverand¢re som man laver ordre for.';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(5154; "Salespersoncode on Salesdoc."; Option)
        {
            Caption = 'Salesperson Code On Sales Documents';
            DataClassification = CustomerContent;
            Description = 'Opsætning for sælgerkode på salgsbilag';
            OptionCaption = 'Forced,Free';
            OptionMembers = Forced,Free;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(6211; "Password on unblock discount"; Text[4])
        {
            Caption = 'Administrator Password';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(6215; "Retail Journal No. Series"; Code[20])
        {
            Caption = 'Retail Journal No. Series';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(6233; "Costing Method Standard"; Enum "Costing Method")
        {
            Caption = 'Costing Method Std.';
            DataClassification = CustomerContent;
            InitValue = Standard;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(6270; "Margin and Turnover By Shop"; Option)
        {
            Caption = 'Margin And Turnover By Shop';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Dimension1,Dimension2';
            OptionMembers = " ",Dimension1,Dimension2;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(10000; "Data Model Build"; Integer)
        {
            Caption = 'Data Model Build';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(10001; "Last Data Model Build Upgrade"; DateTime)
        {
            Caption = 'Last Data Model Build Upgrade';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(10002; "Last Data Model Build User ID"; Code[50])
        {
            Caption = 'Last Data Model Build User ID';
            DataClassification = EndUserIdentifiableInformation;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field is not being used anymore';
        }
        field(10003; "Prev. Data Model Build"; Integer)
        {
            Caption = 'Prev. Data Model Build';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(10010; "Advanced POS Entries Activated"; Boolean)
        {
            Caption = 'Advanced POS Entries Activated';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(10020; "Advanced Posting Activated"; Boolean)
        {
            Caption = 'Advanced Posting Activated';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(20000; "Environment Database Name"; Text[250])
        {
            Caption = 'Environment Database Name';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(20001; "Environment Company Name"; Text[250])
        {
            Caption = 'Environment Company Name';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(20002; "Environment Tenant Name"; Text[250])
        {
            Caption = 'Environment Tenant Name';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(20003; "Environment Type"; Option)
        {
            Caption = 'Environment Type';
            DataClassification = CustomerContent;
            OptionCaption = 'PROD,DEMO,TEST,DEV';
            OptionMembers = PROD,DEMO,TEST,DEV;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(20004; "Environment Verified"; Boolean)
        {
            Caption = 'Environment Verified';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(20005; "Environment Template"; Boolean)
        {
            Caption = 'Environment Template';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'NPR Environment module is obsolete and will be removed';
        }
        field(30000; "Enable Client Diagnostics"; Boolean)
        {
            Caption = 'Enable Client Diagnostics';
            DataClassification = CustomerContent;
            Description = 'NPR5.38,NPR5.40';
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
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
}

