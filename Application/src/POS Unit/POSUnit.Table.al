table 6150615 "NPR POS Unit"
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
            Description = 'NPR5.54';
            OptionCaption = 'Attended,Unattended';
            OptionMembers = ATTENDED,UNATTENDED;
        }
        field(200; "Ean Box Sales Setup"; Code[20])
        {
            Caption = 'Ean Box Sales Setup';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
            TableRelation = "NPR Ean Box Setup" WHERE("POS View" = CONST(Sale));
        }
        field(205; "POS Sales Workflow Set"; Code[20])
        {
            Caption = 'POS Sales Workflow Set';
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
            Caption = 'Global POS Sales Setup';
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
            TableRelation = "NPR POS Posting Profile";
            NotBlank = true;
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
            TableRelation = "NPR MPOS Profile";
        }
        field(600; "POS Self Service Profile"; Code[20])
        {
            Caption = 'POS Self Service Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR SS Profile";
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
        Modify;
    end;

    procedure GetPostingProfile(POSUnitNo: Code[10]; var POSPostingProfile: Record "NPR POS Posting Profile")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(POSUnitNo);
        POSUnit.TestField("POS Posting Profile");
        POSPostingProfile.Get(POSUnit."POS Posting Profile");
    end;

    procedure GetProfile(var POSPricingProfile: Record "NPR POS Pricing Profile"): Boolean
    begin
        Clear(POSPricingProfile);
        if "POS Pricing Profile" = '' then
            exit;
        exit(POSPricingProfile.Get("POS Posting Profile"));
    end;

    procedure GetProfile(var MPOSProfile: Record "NPR MPOS Profile"): Boolean
    begin
        Clear(MPOSProfile);
        if "MPOS Profile" = '' then
            exit;
        exit(MPOSProfile.Get("MPOS Profile"));
    end;

    procedure GetProfile(var POSViewProfile: Record "NPR POS View Profile"): Boolean
    begin
        Clear(POSViewProfile);
        if "POS View Profile" = '' then
            exit;
        exit(POSViewProfile.Get("POS View Profile"));
    end;

    procedure GetProfile(var SSProfile: Record "NPR SS Profile"): Boolean
    begin
        Clear(SSProfile);
        if "POS View Profile" = '' then
            exit;
        exit(SSProfile.Get("POS View Profile"));
    end;

    procedure GetCurrentPOSUnit(): Code[10]
    var
        UserSetup: Record "User Setup";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        if POSSession.GetSession(POSSession, false) then begin
            POSSession.GetSetup(POSSetup);
            exit(POSSetup.Register());
        end;

        if not UserSetup.Get(UserId) then
            exit('?'); //Old syntax - kept in case anyone matches on question mark.
        exit(UserSetup."NPR Backoffice Register No.");
    end;

    procedure FindActiveEventFromCurrPOSUnit(): Code[20]
    var
        POSUnitEvent: Record "NPR POS Unit Event";
    begin
        exit(POSUnitEvent.FindActiveEvent(Rec."No."));
    end;

    procedure SetActiveEventForCurrPOSUnit(EventNo: Code[20])
    var
        POSUnitEvent: Record "NPR POS Unit Event";
    begin
        POSUnitEvent.SetActiveEvent(Rec."No.", EventNo);
    end;

    procedure DeleteActiveEventForCurrPOSUnit()
    var
        POSUnitEvent: Record "NPR POS Unit Event";
    begin
        POSUnitEvent.DeleteActiveEvent(Rec."No.");
    end;
}

