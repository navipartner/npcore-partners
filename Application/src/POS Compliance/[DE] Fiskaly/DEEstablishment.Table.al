table 6150994 "NPR DE Establishment"
{
    Access = Internal;
    Caption = 'DE Establishment';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR DE Establishments";
    LookupPageId = "NPR DE Establishments";

    fields
    {
        field(1; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code (Establishment)';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Store";

            trigger OnValidate()
            var
                POSStore: Record "NPR POS Store";
            begin
                if "POS Store Code" <> xRec."POS Store Code" then begin
                    Clear(Description);
                    if POSStore.Get("POS Store Code") then
                        SetDefaultAddressFieldValues(POSStore);
                end;
            end;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Connection Parameter Set Code"; Code[10])
        {
            Caption = 'Connection Parameter Set Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR DE Audit Setup";

            trigger OnValidate()
            begin
                if "Connection Parameter Set Code" <> xRec."Connection Parameter Set Code" then
                    TestField(Created, false);
            end;
        }
        field(30; Created; Boolean)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(35; Decommissioned; Boolean)
        {
            Caption = 'Decommissioned';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; Street; Text[100])
        {
            Caption = 'Street';
            DataClassification = CustomerContent;
        }
        field(50; "House Number"; Code[4])
        {
            Caption = 'House Number';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "House Number" <> '' then
                    DEFiskalyCommunication.CheckIsValueAccordingToAllowedPattern("House Number", GetHouseNumberPattern());
            end;
        }
        field(60; "House Number Suffix"; Text[20])
        {
            Caption = 'House Number Suffix';
            DataClassification = CustomerContent;
        }
        field(70; Town; Text[50])
        {
            Caption = 'Town';
            DataClassification = CustomerContent;
        }
        field(80; "ZIP Code"; Code[20])
        {
            Caption = 'ZIP Code';
            DataClassification = CustomerContent;
        }
        field(90; "Additional Address"; Text[50])
        {
            Caption = 'Additional Address';
            DataClassification = CustomerContent;
        }
        field(100; "Decommissioning Date"; Date)
        {
            Caption = 'Decommissioning Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Decommissioning Date" <> xRec."Decommissioning Date" then
                    TestField(Decommissioned, false);
            end;
        }
        field(110; Designation; Text[200])
        {
            Caption = 'Designation';
            DataClassification = CustomerContent;
        }
        field(120; Remarks; Text[1000])
        {
            Caption = 'Remarks';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "POS Store Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        SystemId := CreateGuid();
    end;

    trigger OnDelete()
    var
        DETSSClient: Record "NPR DE POS Unit Aux. Info";
        ConfirmManagement: Codeunit "Confirm Management";
        CannotDeleteErr: Label 'You cannot delete %1 %2 since there is at least one related %3 which has been already created at Fiskaly. You must delete this record(s) first.', Comment = '%1 - DE Establishment table caption, %2 - DE Establishment Code field value, %3 - DE POS Unit Aux. Info table caption';
        DeleteConfirmQst: Label 'Are you sure that you want to delete %1 %2 since it has been already sent to Fiskaly and it can cause data discrepancy?', Comment = '%1 - DE Establishment table caption, %2 - POS Store Code field value';
    begin
        DETSSClient.SetRange("POS Store Code", "POS Store Code");
        DETSSClient.SetRange("Additional Data Created", true);
        if not DETSSClient.IsEmpty() then
            Error(CannotDeleteErr, TableCaption(), "POS Store Code", DETSSClient.TableCaption());

        if Created then
            if not ConfirmManagement.GetResponse(StrSubstNo(DeleteConfirmQst, TableCaption(), "POS Store Code"), false) then
                Error('');
    end;

    trigger OnRename()
    var
        CannotRenameErr: Label 'You cannot rename a %1 %2 since it has been already sent to Fiskaly and it can cause data discrepancy.', Comment = '%1 - DE Establishment table caption, %2 - POS Store Code field value';
    begin
        if Created then
            Error(CannotRenameErr, TableCaption(), "POS Store Code");
    end;

    var
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";

    local procedure SetDefaultAddressFieldValues(POSStore: Record "NPR POS Store")
    begin
        Description := POSStore.Name;
        Street := POSStore.Address;
        Town := POSStore.City;
        "ZIP Code" := POSStore."Post Code";
    end;

    local procedure GetHouseNumberPattern(): Text;
    var
        PatternLbl: Label '^[0-9]{1,4}$', Locked = true;
    begin
        exit(PatternLbl);
    end;

    internal procedure GetWithCheck(POSStoreCode: Code[10])
    begin
        Get(POSStoreCode);
        TestField(Created);
    end;
}