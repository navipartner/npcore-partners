﻿table 6150615 "NPR POS Unit"
{
    Caption = 'POS Unit';
    DataClassification = CustomerContent;
    DataCaptionFields = "No.", Name;
    DrillDownPageID = "NPR POS Unit List";
    LookupPageID = "NPR POS Unit List";

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
            trigger OnValidate()
            var
                StoreCodeChangeLabel: Label 'It is not recommended to change the store code during an active workshift. You can close the workshift from the POS unit using the Z-Report (end-of-day) functionality.';
            begin
                if (Status <> Status::CLOSED) then
                    Error(StoreCodeChangeLabel);
            end;
        }
        field(11; "Default POS Payment Bin"; Code[10])
        {
            Caption = 'Default POS Payment Bin';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin";
        }
        field(20; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            InitValue = CLOSED;
            OptionCaption = 'Open,Closed,End of Day';
            OptionMembers = OPEN,CLOSED,EOD;
        }
        field(30; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(31; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(40; "Lock Timeout"; Option)
        {
            Caption = 'Lock Timeout';
            DataClassification = CustomerContent;
            OptionCaption = 'Never,30 Seconds,60 Seconds,90 Seconds,120 Seconds,600 Seconds';
            OptionMembers = NEVER,"30S","60S","90S","120S","600S";
            ObsoleteState = Removed;
            ObsoleteReason = 'Move to dedicated POS Unit Profile';
            ObsoleteTag = 'NPR POS Unit -> NPR POS View Profile';
        }
        field(50; "Kiosk Mode Unlock PIN"; Text[30])
        {
            Caption = 'Kiosk Mode Unlock PIN';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
            ObsoleteState = Removed;
            ObsoleteReason = 'Move to dedicated POS Unit Profile';
            ObsoleteTag = 'NPR POS Unit -> NPR POS SS Profile';
        }
        field(60; "POS Type"; Option)
        {
            Caption = 'POS Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Full/Fixed,Unattended,mPos,External';
            OptionMembers = "FULL/FIXED",UNATTENDED,MPOS,EXTERNAL;
        }
        field(200; "Ean Box Sales Setup"; Code[20])
        {
            Caption = 'POS Input Box Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
            TableRelation = "NPR Ean Box Setup" WHERE("POS View" = CONST(Sale));
        }
        field(205; "POS Sales Workflow Set"; Code[20])
        {
            Caption = 'POS Scenarios Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
            TableRelation = "NPR POS Sales Workflow Set";
        }
        field(300; "Item Price Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Item Price Codeunit ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
            ObsoleteState = Removed;
            ObsoleteReason = 'Move to dedicated POS Unit Profile';
            ObsoleteTag = 'NPR POS Unit -> NPR POS Pricing Profile';
        }
        field(305; "Item Price Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = CONST(6014453)));
            Caption = 'Item Price Codeunit Name';
            Description = 'NPR5.45';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Move to dedicated POS Unit Profile';
            ObsoleteTag = 'NPR POS Unit -> NPR POS Pricing Profile';
        }
        field(310; "Item Price Function"; Text[250])
        {
            Caption = 'Item Price Function';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
            ObsoleteState = Removed;
            ObsoleteReason = 'Move to dedicated POS Unit Profile';
            ObsoleteTag = 'NPR POS Unit -> NPR POS Pricing Profile';
        }
        field(400; "Global POS Sales Setup"; Code[10])
        {
            Caption = 'POS Global Sales Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            TableRelation = "NPR NpGp POS Sales Setup";
        }

        field(500; "POS Audit Profile"; Code[20])
        {
            Caption = 'POS Audit Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Audit Profile";
        }
        field(501; "POS View Profile"; Code[20])
        {
            Caption = 'POS View Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
            TableRelation = "NPR POS View Profile";
        }
        field(510; "POS End of Day Profile"; Code[20])
        {
            Caption = 'POS End of Day Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS End of Day Profile";
        }
        field(520; "POS Posting Profile"; Code[20])
        {
            Caption = 'POS Posting Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            NotBlank = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to POS Store';
            ObsoleteTag = 'POS Unit -> POS Store';

        }
        field(530; "POS Inventory Profile"; Code[20])
        {
            Caption = 'POS Inventory Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Inventory Profile";
        }
        field(540; "POS Unit Receipt Text Profile"; Code[20])
        {
            Caption = 'POS Unit Receipt Text Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR POS Unit Rcpt.Txt Profile";
        }
        field(550; "POS Named Actions Profile"; Code[20])
        {
            Caption = 'POS Named Actions Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR POS Setup";
        }
        field(560; "POS Unit Serial No"; Code[20])
        {
            Caption = 'POS Unit Serial No';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            ObsoleteState = Removed;
            ObsoleteReason = 'Doesn''t have any reference';
        }
        field(570; "POS Restaurant Profile"; Code[20])
        {
            Caption = 'POS Restaurant Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR POS NPRE Rest. Profile";
        }
        field(580; "POS Pricing Profile"; Code[20])
        {
            Caption = 'POS Pricing Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Pricing Profile";
        }
        field(590; "MPOS Profile"; Code[20])
        {
            Caption = 'MPOS Profile';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = '1. Field "Ticket Admission Web Url" moved from MPOS Profile table to table "NPR TM Ticket Setup". 2. Use field "POS Type" to identify if the POS is an mPos device.';
        }
        field(600; "POS Self Service Profile"; Code[20])
        {
            Caption = 'POS Self Service Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR SS Profile";
        }
        field(610; "POS Display Profile"; Code[10])
        {
            Caption = 'POS Display Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR Display Setup";

            trigger OnValidate()
            var
                UnitDisplay: Record "NPR POS Unit Display";
            begin
                if (Rec."POS Display Profile" <> '') then
                    if (UnitDisplay.Get(Rec."POS Display Profile")) then begin
                        UnitDisplay."Media Downloaded" := false;
                        UnitDisplay.Modify();
                    end;
            end;
        }
        field(620; "POS Security Profile"; Code[20])
        {
            Caption = 'POS Security Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Security Profile";
        }
        field(5058; "Open Register Password"; Code[20])
        {
            Caption = 'Open POS Unit Password';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to POS View Profile';
        }
        field(6211; "Password on unblock discount"; Text[4])
        {
            Caption = 'Administrator Password';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to POS View Profile';
        }
        field(630; "POS Tax Free Profile"; Code[10])
        {
            Caption = 'POS Tax Free Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR Tax Free POS Unit";
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "POS Store Code", Name)
        {
        }
    }

    trigger OnDelete()
    begin
        DimMgt.DeleteDefaultDim(DATABASE::"NPR POS Unit", "No.");
        DeleteActiveEventForCurrPOSUnit();
    end;

    trigger OnInsert()
    begin
        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR POS Unit", "No.",
          "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    var
        DimMgt: Codeunit DimensionManagement;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR POS Unit", "No.", FieldNumber, ShortcutDimCode);
        Modify();
    end;


    [Obsolete('Use codeunit "NPR POS Pricing Profile"')]
    procedure GetProfile(var POSPricingProfile: Record "NPR POS Pricing Profile"): Boolean
    begin
        Clear(POSPricingProfile);
        if "POS Pricing Profile" = '' then
            exit;
        exit(POSPricingProfile.Get("POS Pricing Profile"));
    end;

    procedure GetProfile(var POSViewProfile: Record "NPR POS View Profile"): Boolean
    begin
        Clear(POSViewProfile);
        if "POS View Profile" = '' then
            exit;
        exit(POSViewProfile.Get("POS View Profile"));
    end;

    [Obsolete('Use codeunit "NPR Self Service Profile"')]
    procedure GetProfile(var SSProfile: Record "NPR SS Profile"): Boolean
    begin
        Clear(SSProfile);
        if "POS Self Service Profile" = '' then
            exit;
        exit(SSProfile.Get("POS Self Service Profile"));
    end;


    [Obsolete('Use codeunit "NPR POS Proxy - Display"')]
    procedure GetProfile(var DisplayProfile: Record "NPR Display Setup"): Boolean
    begin
        Clear(DisplayProfile);
        if "POS Display Profile" = '' then
            exit;
        exit(DisplayProfile.Get("POS Display Profile"));
    end;

    [Obsolete('Use module "Tax Free"')]
    procedure GetProfile(var TaxFreeProfile: Record "NPR Tax Free POS Unit"): Boolean
    begin
        Clear(TaxFreeProfile);
        if "POS Tax Free Profile" = '' then
            exit;
        exit(TaxFreeProfile.Get("POS Tax Free Profile"));
    end;

    [Obsolete('Use codeunit "NPR POS Security Profile"')]
    procedure GetProfile(var SecurityProfile: Record "NPR POS Security Profile"): Boolean
    begin
        Clear(SecurityProfile);
        if "POS Security Profile" = '' then
            exit;
        exit(SecurityProfile.Get("POS Security Profile"));
    end;

    procedure GetProfile(var POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    begin
        Clear(POSAuditProfile);
        if "POS Audit Profile" = '' then
            exit;
        exit(POSAuditProfile.Get("POS Audit Profile"));
    end;

    procedure GetProfile(var POSEoDProfile: Record "NPR POS End of Day Profile"): Boolean
    begin
        Clear(POSEoDProfile);
        if "POS End of Day Profile" = '' then
            exit;
        exit(POSEoDProfile.Get("POS End of Day Profile"));
    end;

    [Obsolete('For public access use codeunit "NPR POS Inventory Profile"')]
    procedure GetProfile(var PosInventoryProfile: Record "NPR POS Inventory Profile"): Boolean
    begin
        Clear(PosInventoryProfile);
        if "POS Inventory Profile" = '' then
            exit;
        exit(PosInventoryProfile.Get("POS Inventory Profile"));
    end;

    internal procedure GetCurrentPOSUnit(): Code[10]
    var
        UserSetup: Record "User Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        UserSetup.Get(UserId);
        UserSetup.TestField("NPR POS Unit No.");
        POSUnit.Get(UserSetup."NPR POS Unit No.");
        exit(POSUnit."No.");
    end;

    procedure FindActiveEventFromCurrPOSUnit(): Code[20]
    var
        POSUnitEvent: Record "NPR POS Unit Event";
    begin
        exit(POSUnitEvent.FindActiveEvent(Rec."No."));
    end;

    internal procedure SetActiveEventForCurrPOSUnit(EventNo: Code[20])
    var
        POSUnitEvent: Record "NPR POS Unit Event";
    begin
        POSUnitEvent.SetActiveEvent(Rec."No.", EventNo);
    end;

    internal procedure DeleteActiveEventForCurrPOSUnit()
    var
        POSUnitEvent: Record "NPR POS Unit Event";
    begin
        POSUnitEvent.DeleteActiveEvent(Rec."No.");
    end;

    internal procedure ShowPricesIncludingVAT(): Boolean
    var
        PosViewProfile: Record "NPR POS View Profile";
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        if GetProfile(PosViewProfile) then
            exit(PosViewProfile."Show Prices Including VAT");
        exit(not ApplicationAreaMgmt.IsSalesTaxEnabled());
    end;
}
