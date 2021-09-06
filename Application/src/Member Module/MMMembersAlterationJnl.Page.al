page 6060073 "NPR MM Members. Alteration Jnl"
{

    Caption = 'Membership Alteration Journal';
    PageType = List;
    SourceTable = "NPR MM Member Info Capture";
    SourceTableView = WHERE("Source Type" = CONST(ALTERATION_JNL));
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; AlterationOption)
                {

                    OptionCaption = ' ,Regret,Renew,Upgrade,Extend,Cancel';
                    ToolTip = 'Specifies the value of the AlterationOption field';
                    ApplicationArea = NPRRetail;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipLookup();
                    end;

                    trigger OnValidate()
                    begin

                        SetExternalMembershipNo(Rec."External Membership No.", Rec);
                    end;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        ItemLookup();
                    end;

                    trigger OnValidate()
                    begin

                        SetItemNo(Rec."Item No.", Rec);
                    end;
                }
                field("Document Date"; Rec."Document Date")
                {

                    ToolTip = 'Specifies the value of the Document Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Response Status"; Rec."Response Status")
                {

                    ToolTip = 'Specifies the value of the Response Status field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin

                        Rec."Response Message" := '';
                    end;
                }
                field("Response Message"; Rec."Response Message")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Response Message field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Check)
            {
                Caption = 'Check';
                Image = TestReport;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Check action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin

                    AlterMemberships(false);
                end;
            }
            action("Check and Execute")
            {
                Caption = 'Check and Execute';
                Ellipsis = true;
                Image = PostBatch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Check and Execute action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin

                    AlterMemberships(true);
                end;
            }
            action("Batch Renew")
            {
                Caption = 'Batch Renew';
                Ellipsis = true;
                Image = CalculatePlan;

                ToolTip = 'Executes the Batch Renew action';
                ApplicationArea = NPRRetail;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    BatchRenewReport: Report "NPR MM Membership Batch Renew";
                begin

                    BatchRenewReport.LaunchAlterationJnlPage(false);
                    BatchRenewReport.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action("Import From File")
            {
                Caption = 'Import From File';
                Ellipsis = true;
                Image = Import;

                ToolTip = 'Executes the Import From File action';
                ApplicationArea = NPRRetail;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    SkipFirstLine: Boolean;
                begin

                    SkipFirstLine := Confirm(FILE_HAS_HEADINGS, true);
                    ImportAlterationFromFile(SkipFirstLine);
                    CurrPage.Update(false);

                end;
            }
        }
        area(navigation)
        {
            action("Membership Setup")
            {
                Caption = 'Membership Setup';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Setup";
                RunPageLink = Code = FIELD("Membership Code");

                ToolTip = 'Executes the Membership Setup action';
                ApplicationArea = NPRRetail;
            }
            action("Membership Card")
            {
                Caption = 'Membership Card';
                Image = Customer;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Membership Entry No.");

                ToolTip = 'Executes the Membership Card action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        case Rec."Information Context" of
            Rec."Information Context"::REGRET:
                AlterationOption := AlterationOption::REGRET;
            Rec."Information Context"::RENEW:
                AlterationOption := AlterationOption::RENEW;
            Rec."Information Context"::UPGRADE:
                AlterationOption := AlterationOption::UPGRADE;
            Rec."Information Context"::EXTEND:
                AlterationOption := AlterationOption::EXTEND;
            Rec."Information Context"::CANCEL:
                AlterationOption := AlterationOption::CANCEL;
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

        SetInformationContext(AlterationOption, Rec);
    end;

    trigger OnModifyRecord(): Boolean
    begin

        SetInformationContext(AlterationOption, Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Source Type" := Rec."Source Type"::ALTERATION_JNL;
        Rec."Document Date" := WorkDate();
    end;

    var
        AlterationOption: Option " ",REGRET,RENEW,UPGRADE,EXTEND,CANCEL;
        CONFIRM_EXECUTE: Label '%1 lines are selected. Are you sure you want to make the selected changes? ';
        GDateMask: Code[20];
        IMPORT_MESSAGE_DIALOG: Label 'Importing :\#1#######################################################';
        GLineCount: Integer;
        FldAlterationType: Text;
        FldExternalNumber: Text;
        FldAlterationItemNo: Text;
        FldAlterationDate: Text;
        REQUIRED: Integer;
        OPTIONAL: Integer;
        SELECT_FILE_CAPTION: Label 'Membership Alteration Import';
        FILE_FILTER: Label 'CSV Files (*.csv)|*.csv|All Files (*.*)|*.*';
        PROCESS_INFO: Label 'Processing: (%1) %2';
        INVALID_LENGTH: Label 'The length of %1 exceeds the max length of %2 for %3 on line %4.';
        VALUE_REQUIRED: Label 'A value is required for field %1 on line %2.';
        DATE_MASK_ERROR: Label 'Date format mask %1 is not supported.';
        INVALID_DATE: Label 'The date %1 specified for field %2 on line %3 does not conform to the expected date format %4.';
        FILE_HAS_HEADINGS: Label 'Does the file have headings on the first line?';

    local procedure SetInformationContext(pType: Option; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin

        case pType of
            AlterationOption::REGRET:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::REGRET;
            AlterationOption::RENEW:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
            AlterationOption::UPGRADE:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::UPGRADE;
            AlterationOption::EXTEND:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::EXTEND;
            AlterationOption::CANCEL:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::CANCEL;
        end;
    end;

    local procedure MembershipLookup()
    var
        MembershipListPage: Page "NPR MM Memberships";
        Membership: Record "NPR MM Membership";
        PageAction: Action;
    begin

        Membership.SetFilter(Blocked, '=%1', false);
        MembershipListPage.SetTableView(Membership);
        MembershipListPage.LookupMode(true);
        PageAction := MembershipListPage.RunModal();

        if (PageAction <> ACTION::LookupOK) then
            exit;

        MembershipListPage.GetRecord(Membership);
        SetExternalMembershipNo(Membership."External Membership No.", Rec);
    end;

    local procedure ItemLookup()
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipAlterationPage: Page "NPR MM Membership Alter.";
        PageAction: Action;
    begin

        MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', GetAlterationType(AlterationOption));
        Rec.TestField("Membership Code");
        MembershipAlterationSetup.SetFilter("From Membership Code", '=%1', Rec."Membership Code");
        MembershipAlterationPage.SetTableView(MembershipAlterationSetup);
        MembershipAlterationPage.LookupMode(true);
        PageAction := MembershipAlterationPage.RunModal();

        if (PageAction <> ACTION::LookupOK) then
            exit;

        MembershipAlterationPage.GetRecord(MembershipAlterationSetup);
        SetItemNo(MembershipAlterationSetup."Sales Item No.", Rec);
    end;

    local procedure SetExternalMembershipNo(pExternalMembershipNo: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Membership: Record "NPR MM Membership";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        if (pExternalMembershipNo = '') then begin
            MemberInfoCapture."Membership Entry No." := 0;
            MemberInfoCapture."External Membership No." := pExternalMembershipNo;
            MemberInfoCapture."Membership Code" := '';
            exit;
        end;

        Membership.SetFilter("External Membership No.", '=%1', pExternalMembershipNo);
        if (not Membership.FindFirst()) then begin
            Membership.Reset();
            Membership.SetFilter("Customer No.", '=%1', pExternalMembershipNo);
            Membership.SetFilter(Blocked, '=%1', false);
            if not (Membership.FindFirst()) then begin
                Membership.Reset();
                Membership.SetFilter("External Membership No.", '=%1', pExternalMembershipNo);

                if (not Membership.FindFirst()) then begin
                    MemberInfoCapture."External Member No" := pExternalMembershipNo;
                    MemberInfoCapture."Response Message" := 'Invalid reference.';
                    MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::FAILED;
                    exit;
                end;

            end;
        end;

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Membership Code" := Membership."Membership Code";

        if (MemberInfoCapture."Membership Code" <> '') then begin
            MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', GetAlterationType(AlterationOption));
            MembershipAlterationSetup.SetFilter("From Membership Code", '=%1', MemberInfoCapture."Membership Code");
            if (MembershipAlterationSetup.Count() = 1) then begin
                MembershipAlterationSetup.FindFirst();
                SetItemNo(MembershipAlterationSetup."Sales Item No.", MemberInfoCapture);
            end;
        end;
    end;

    local procedure SetItemNo(ItemNo: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        MemberInfoCapture."Item No." := ItemNo;
        MemberInfoCapture.Description := MembershipAlterationSetup.Description;
        if (ItemNo = '') then
            exit;

        MembershipAlterationSetup.Get(GetAlterationType(AlterationOption), MemberInfoCapture."Membership Code", ItemNo);
        MemberInfoCapture."Item No." := ItemNo;
        MemberInfoCapture.Description := MembershipAlterationSetup.Description;
    end;

    local procedure GetAlterationType(pAlterationOption: Option): Integer
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        case pAlterationOption of
            AlterationOption::RENEW:
                MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::RENEW;
            AlterationOption::UPGRADE:
                MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::UPGRADE;
            AlterationOption::EXTEND:
                MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::EXTEND;
            AlterationOption::CANCEL:
                MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::CANCEL;
            AlterationOption::REGRET:
                MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::REGRET;
            else
                Error('Type must be selected.');
        end;

        exit(MembershipAlterationSetup."Alteration Type");
    end;

    local procedure AlterMemberships(CheckAndExecute: Boolean)
    var
        AlterationJnlMgmt: Codeunit "NPR MM Alteration Jnl Mgmt";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        SelectionCount: Integer;
    begin

        CurrPage.SetSelectionFilter(MemberInfoCapture);
        MemberInfoCapture.SetFilter("Source Type", '=%1', MemberInfoCapture."Source Type"::ALTERATION_JNL);
        if (MemberInfoCapture.FindSet()) then begin

            SelectionCount := MemberInfoCapture.Count();
            AlterationJnlMgmt.SetRequestUserConfirmation(SelectionCount = 1);

            if ((SelectionCount > 1) and (CheckAndExecute)) then
                if (not Confirm(CONFIRM_EXECUTE, true, SelectionCount)) then
                    Error('');

            repeat

                if (MemberInfoCapture."Response Status" in [Rec."Response Status"::REGISTERED, Rec."Response Status"::FAILED]) then begin
                    MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::REGISTERED;
                    AlterationJnlMgmt.AlterMembership(MemberInfoCapture);
                    MemberInfoCapture.Modify();
                    AlterationJnlMgmt.SetRequestUserConfirmation(false);
                end;

                if (CheckAndExecute) then begin
                    if (MemberInfoCapture."Response Status" = MemberInfoCapture."Response Status"::READY) then begin
                        AlterationJnlMgmt.AlterMembership(MemberInfoCapture);
                        MemberInfoCapture.Modify();
                    end;

                    if (MemberInfoCapture."Response Status" = MemberInfoCapture."Response Status"::COMPLETED) then
                        MemberInfoCapture.Delete();
                end;

            until (MemberInfoCapture.Next() = 0);
        end;

        CurrPage.Update(false);
    end;

    local procedure SelectMembershipUsingMemberCard(ExternalCardNumber: Text[100]; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
    begin

        MemberCard.SetFilter("External Card No.", '=%1', ExternalCardNumber);
        if (not MemberCard.FindFirst()) then
            exit(false);

        if (MemberCard.Blocked) then
            MemberCard.TestField(Blocked);

        Membership.Get(MemberCard."Membership Entry No.");
        SetExternalMembershipNo(Membership."External Membership No.", MemberInfoCapture);
        exit(true);
    end;

    local procedure ImportAlterationFromFile(SkipFirstLine: Boolean)
    var
        FileManagement: Codeunit "File Management";
        TempBLOB: Codeunit "Temp Blob";
    begin
        FileManagement.BLOBImportWithFilter(TempBLOB, SELECT_FILE_CAPTION, '', FILE_FILTER, 'csv');
        ImportFromFile(TempBLOB, SkipFirstLine);
    end;

    procedure ImportFromFile(TempBLOB: Codeunit "Temp Blob"; SkipFirstLine: Boolean)
    var
        IStream: InStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Fileline: Text;
        Window: Dialog;
    begin

        REQUIRED := 1;
        OPTIONAL := 2;

        GDateMask := 'YYYYMMDD'; // Should be setup or parameter


        TempBLOB.CreateInStream(IStream);

        if (not MemberInfoCapture.FindLast()) then;

        if GuiAllowed then
            Window.Open(IMPORT_MESSAGE_DIALOG);

        while (not IStream.EOS) do begin

            if (IStream.ReadText(Fileline) > 0) then begin

                // UTF-8 files start with some bytes identifying the format, get rid of those bytes
                DecodeLine(Fileline);

                if GuiAllowed then
                    if ((GLineCount mod 5) = 0) then Window.Update(1, StrSubstNo(PROCESS_INFO, GLineCount, FldExternalNumber));

                GLineCount += 1;

                if ((SkipFirstLine) and (GLineCount <> 1)) or (not SkipFirstLine) then begin
                    InsertLine();
                end;

            end;

        end;
        if GuiAllowed then
            Window.Close();

    end;

    local procedure DecodeLine(CsvLine: Text)
    begin

        FldAlterationType := nextField(CsvLine);
        FldExternalNumber := nextField(CsvLine);
        FldAlterationItemNo := nextField(CsvLine);
        FldAlterationDate := nextField(CsvLine);

        validateTextField(FldAlterationType, 20, REQUIRED, Rec.FieldCaption("Information Context"));
        validateTextField(FldExternalNumber, MaxStrLen(Rec."External Membership No."), REQUIRED, Rec.FieldCaption("External Membership No."));
        validateTextField(FldAlterationItemNo, MaxStrLen(Rec."Item No."), OPTIONAL, Rec.FieldCaption("Item No."));
        validateDateField(FldAlterationDate, GDateMask, OPTIONAL, Rec.FieldCaption("Document Date"));
    end;

    local procedure InsertLine()
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::ALTERATION_JNL;
        MemberInfoCapture."Document No." := CopyStr(UserId, 1, MaxStrLen(MemberInfoCapture."Document No."));

        case LowerCase(FldAlterationType) of
            'renew':
                AlterationOption := AlterationOption::RENEW;
            'upgrade':
                AlterationOption := AlterationOption::UPGRADE;
            'extend':
                AlterationOption := AlterationOption::EXTEND;
            'regret':
                AlterationOption := AlterationOption::REGRET;
            'cancel':
                AlterationOption := AlterationOption::CANCEL;
            else
                exit;
        end;
        SetInformationContext(AlterationOption, MemberInfoCapture);

        if (not SelectMembershipUsingMemberCard(CopyStr(FldExternalNumber, 1, 100), MemberInfoCapture)) then
            SetExternalMembershipNo(CopyStr(FldExternalNumber, 1, 20), MemberInfoCapture);

        if (MemberInfoCapture."Item No." = '') then
            validateTextField(FldAlterationItemNo, MaxStrLen(Rec."Item No."), REQUIRED, Rec.FieldCaption("Item No."));

        if (FldAlterationItemNo <> '') then
            SetItemNo(CopyStr(FldAlterationItemNo, 1, 20), MemberInfoCapture);

        MemberInfoCapture."Document Date" := Today();
        if (FldAlterationDate <> '') then
            MemberInfoCapture."Document Date" := validateDateField(FldAlterationDate, GDateMask, REQUIRED, Rec.FieldCaption("Document Date"));

        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::REGISTERED;
        MemberInfoCapture."Originates From File Import" := true;

        MemberInfoCapture.Insert();

    end;

    local procedure validateTextField(fieldValue: Text; fieldMaxLength: Integer; fieldValueIs: Integer; fieldCaptionName: Text): Text
    begin

        if (StrLen(fieldValue) > fieldMaxLength) then
            Error(INVALID_LENGTH, fieldValue, fieldMaxLength, fieldCaptionName, GLineCount);

        if ((fieldValue = '') and (fieldValueIs = REQUIRED)) then
            Error(VALUE_REQUIRED, fieldCaptionName, GLineCount);

        exit(fieldValue);

    end;

    local procedure validateDateField(fieldValue: Text; dateMask: Code[20]; fieldValueIs: Integer; fieldCaptionName: Text) rDate: Date
    var
        PlaceHolderLbl: Label '%1-%2-%3', Locked = true;
    begin
        rDate := 0D;

        if ((fieldValue = '') and (fieldValueIs = REQUIRED)) then
            Error(VALUE_REQUIRED, fieldCaptionName, GLineCount);

        if ((fieldValue = '') and (fieldValueIs = OPTIONAL)) then
            exit(0D);

        if (StrLen(fieldValue) <> StrLen(dateMask)) then
            Error(INVALID_DATE, fieldValue, fieldCaptionName, GLineCount, dateMask);

        case UpperCase(dateMask) of
            'YYYYMMDD':
                if (not Evaluate(rDate, StrSubstNo(PlaceHolderLbl, CopyStr(fieldValue, 1, 4), CopyStr(fieldValue, 5, 2), CopyStr(fieldValue, 7, 2)), 9)) then
                    Error(INVALID_DATE, fieldValue, fieldCaptionName, GLineCount, dateMask);

            'YYYY-MM-DD':
                if (not Evaluate(rDate, StrSubstNo(PlaceHolderLbl, CopyStr(fieldValue, 1, 4), CopyStr(fieldValue, 6, 2), CopyStr(fieldValue, 9, 2)), 9)) then
                    Error(INVALID_DATE, fieldValue, fieldCaptionName, GLineCount, dateMask);

            else
                Error(DATE_MASK_ERROR, dateMask);
        end;

        exit(rDate);

    end;

    local procedure nextField(var VarLineOfText: Text): Text
    begin

        exit(forwardTokenizer(VarLineOfText, ';', '"'));

    end;

    local procedure forwardTokenizer(var VarText: Text; PSeparator: Char; PQuote: Char) RField: Text
    var
        IsQuoted: Boolean;
        InputText: Text;
        NextFieldPos: Integer;
        IsNextField: Boolean;
        NextByte: Text[1];
    begin

        //  This function splits the textline into 2 parts at first occurence of separator
        //  Quotecharacter enables separator to occur inside datablock

        //  example:
        //  23;some text;"some text with a ;";xxxx

        //  result:
        //  1) 23
        //  2) some text
        //  3) some text with a ;
        //  4) xxxx

        //  Quoted text, variable length text tokenizer:
        //  forward searching tokenizer splitting string at separator.
        //  separator is protected by quoting string
        //  the separator is omitted from the resulting strings

        if ((VarText[1] = PQuote) and (StrLen(VarText) = 1)) then begin
            VarText := '';
            RField := '';
            exit(RField);
        end;

        IsQuoted := false;
        NextFieldPos := 1;
        IsNextField := false;

        InputText := VarText;

        if (PQuote = InputText[NextFieldPos]) then IsQuoted := true;
        while ((NextFieldPos <= StrLen(InputText)) and (not IsNextField)) do begin
            if (PSeparator = InputText[NextFieldPos]) then IsNextField := true;
            if (IsQuoted and IsNextField) then IsNextField := (InputText[NextFieldPos - 1] = PQuote);

            NextByte[1] := InputText[NextFieldPos];
            if (not IsNextField) then RField += NextByte;
            NextFieldPos += 1;
        end;
        if (IsQuoted) then RField := CopyStr(RField, 2, StrLen(RField) - 2);

        VarText := CopyStr(InputText, NextFieldPos);
        exit(RField);

    end;
}

