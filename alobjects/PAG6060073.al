page 6060073 "MM Membership Alteration Jnl"
{
    // MM1.25/TSA /20171213 CASE 299783 Initial Version
    // MM1.26/TSA /20180131 CASE 303546 Added Customer No as alternative search term in external membership no field
    // MM1.34/JDH /20181109 CASE 334163 Added Caption to Actions
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019
    // MM1.43/TSA /20200402 CASE 398329 Added action for batch renew
    // MM1.44/TSA /20200423 CASE 401040 Added importing of alteration data, refactored validation functions
    // MM1.44/TSA /20200423 CASE 401040 Added support for incorrect external reference

    Caption = 'Membership Alteration Journal';
    PageType = List;
    SourceTable = "MM Member Info Capture";
    SourceTableView = WHERE("Source Type"=CONST(ALTERATION_JNL));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Type;AlterationOption)
                {
                    OptionCaption = ' ,Regret,Renew,Upgrade,Extend,Cancel';
                }
                field("External Membership No.";"External Membership No.")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipLookup ();
                    end;

                    trigger OnValidate()
                    begin

                        SetExternalMembershipNo ("External Membership No.", Rec);
                    end;
                }
                field("Membership Code";"Membership Code")
                {
                    Editable = false;
                }
                field("Item No.";"Item No.")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        ItemLookup ();
                    end;

                    trigger OnValidate()
                    begin

                        SetItemNo ("Item No.", Rec);
                    end;
                }
                field("Document Date";"Document Date")
                {
                }
                field(Description;Description)
                {
                }
                field("Response Status";"Response Status")
                {

                    trigger OnValidate()
                    begin

                        "Response Message" := '';
                    end;
                }
                field("Response Message";"Response Message")
                {
                    Editable = false;
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    AlterMemberships (false);
                end;
            }
            action("Check and Execute")
            {
                Caption = 'Check and Execute';
                Ellipsis = true;
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    AlterMemberships (true);
                end;
            }
            action("Batch Renew")
            {
                Caption = 'Batch Renew';
                Ellipsis = true;
                Image = CalculatePlan;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    BatchRenewReport: Report "MM Membership Batch Renew";
                begin

                    BatchRenewReport.LaunchAlterationJnlPage (false);
                    BatchRenewReport.RunModal ();
                    CurrPage.Update (false);
                end;
            }
            action("Import From File")
            {
                Caption = 'Import From File';
                Ellipsis = true;
                Image = Import;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    SkipFirstLine: Boolean;
                begin

                    //-MM1.44 [401040]
                    SkipFirstLine := Confirm (FILE_HAS_HEADINGS, true);
                    ImportAlterationFromFile (SkipFirstLine);
                    CurrPage.Update (false);
                    //+MM1.44 [401040]
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
                PromotedIsBig = true;
                RunObject = Page "MM Membership Setup";
                RunPageLink = Code=FIELD("Membership Code");
            }
            action("Membership Card")
            {
                Caption = 'Membership Card';
                Image = Customer;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "MM Membership Card";
                RunPageLink = "Entry No."=FIELD("Membership Entry No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        case "Information Context" of
          "Information Context"::REGRET : AlterationOption := AlterationOption::REGRET;
          "Information Context"::RENEW  : AlterationOption := AlterationOption::RENEW;
          "Information Context"::UPGRADE : AlterationOption := AlterationOption::UPGRADE;
          "Information Context"::EXTEND : AlterationOption := AlterationOption::EXTEND;
          "Information Context"::CANCEL : AlterationOption := AlterationOption::CANCEL;
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

        SetInformationContext (AlterationOption, Rec);
    end;

    trigger OnModifyRecord(): Boolean
    begin

        SetInformationContext (AlterationOption, Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Source Type" := "Source Type"::ALTERATION_JNL;
        "Document Date" := WorkDate;
    end;

    var
        AlterationOption: Option " ",REGRET,RENEW,UPGRADE,EXTEND,CANCEL;
        CONFIRM_EXECUTE: Label '%1 lines are selected. Are you sure you want to make the selected changes? ';
        GServerFileName: Text;
        GDateMask: Text;
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
        INVALID_VALUE: Label 'The value %1 specified for %2 on line %3 is not valid.';
        INVALID_LENGTH: Label 'The length of %1 exceeds the max length of %2 for %3 on line %4.';
        VALUE_REQUIRED: Label 'A value is required for field %1 on line %2.';
        DATE_MASK_ERROR: Label 'Date format mask %1 is not supported.';
        INVALID_DATE: Label 'The date %1 specified for field %2 on line %3 does not conform to the expected date format %4.';
        FILE_HAS_HEADINGS: Label 'Does the file have headings on the first line?';

    local procedure SetInformationContext(pType: Option;var MemberInfoCapture: Record "MM Member Info Capture")
    begin

        case pType of
          AlterationOption::REGRET : MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::REGRET;
          AlterationOption::RENEW : MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
          AlterationOption::UPGRADE : MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::UPGRADE;
          AlterationOption::EXTEND : MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::EXTEND;
          AlterationOption::CANCEL : MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::CANCEL;
        end;
    end;

    local procedure MembershipLookup()
    var
        MembershipListPage: Page "MM Memberships";
        Membership: Record "MM Membership";
        PageAction: Action;
    begin

        Membership.SetFilter (Blocked, '=%1', false);
        MembershipListPage.SetTableView (Membership);
        MembershipListPage.LookupMode (true);
        PageAction := MembershipListPage.RunModal();

        if (PageAction <> ACTION::LookupOK) then
          exit;

        MembershipListPage.GetRecord (Membership);
        SetExternalMembershipNo (Membership."External Membership No.", Rec);
    end;

    local procedure ItemLookup()
    var
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        MembershipAlterationPage: Page "MM Membership Alteration";
        PageAction: Action;
    begin

        MembershipAlterationSetup.SetFilter ("Alteration Type", '=%1', GetAlterationType (AlterationOption));
        TestField ("Membership Code");
        MembershipAlterationSetup.SetFilter ("From Membership Code", '=%1', "Membership Code");
        MembershipAlterationPage.SetTableView (MembershipAlterationSetup);
        MembershipAlterationPage.LookupMode (true);
        PageAction := MembershipAlterationPage.RunModal ();

        if (PageAction <> ACTION::LookupOK) then
          exit;

        MembershipAlterationPage.GetRecord (MembershipAlterationSetup);
        SetItemNo (MembershipAlterationSetup."Sales Item No.", Rec);
    end;

    local procedure SetExternalMembershipNo(pExternalMembershipNo: Code[20];var MemberInfoCapture: Record "MM Member Info Capture")
    var
        Membership: Record "MM Membership";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
    begin

        if (pExternalMembershipNo = '') then begin
          MemberInfoCapture."Membership Entry No." := 0;
          MemberInfoCapture."External Membership No." := pExternalMembershipNo;
          MemberInfoCapture."Membership Code" := '';
          exit;
        end;

        //-MM1.26 [303546]
        Membership.SetFilter ("External Membership No.", '=%1', pExternalMembershipNo);
        //Membership.FINDFIRST ();
        if (not Membership.FindFirst ()) then begin
          Membership.Reset ();
          Membership.SetFilter ("Customer No.", '=%1', pExternalMembershipNo);
          Membership.SetFilter (Blocked, '=%1', false);
          if not (Membership.FindFirst ()) then begin
            Membership.Reset;
            Membership.SetFilter ("External Membership No.", '=%1', pExternalMembershipNo);
            //-MM1.44 [401040]
            //Membership.FINDFIRST ();
            if (not Membership.FindFirst ()) then begin
              MemberInfoCapture."External Member No" := pExternalMembershipNo;
              MemberInfoCapture."Response Message" := 'Invalid reference.';
              MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::FAILED;
              exit;
            end;
            //+MM1.44 [401040]
          end;
        end;
        //+MM1.26 [303546]

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Membership Code" := Membership."Membership Code";

        if (MemberInfoCapture."Membership Code" <> '') then begin
          MembershipAlterationSetup.SetFilter ("Alteration Type", '=%1', GetAlterationType (AlterationOption));
          MembershipAlterationSetup.SetFilter ("From Membership Code", '=%1', MemberInfoCapture."Membership Code");
          if (MembershipAlterationSetup.Count() = 1) then begin
            MembershipAlterationSetup.FindFirst ();
            SetItemNo (MembershipAlterationSetup."Sales Item No.", MemberInfoCapture);
          end;
        end;
    end;

    local procedure SetItemNo(ItemNo: Code[20];var MemberInfoCapture: Record "MM Member Info Capture")
    var
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
    begin

        MemberInfoCapture."Item No." := ItemNo;
        MemberInfoCapture.Description := MembershipAlterationSetup.Description;
        if (ItemNo = '') then
          exit;

        MembershipAlterationSetup.Get (GetAlterationType (AlterationOption), MemberInfoCapture."Membership Code", ItemNo);
        MemberInfoCapture."Item No." := ItemNo;
        MemberInfoCapture.Description := MembershipAlterationSetup.Description;
    end;

    local procedure GetAlterationType(pAlterationOption: Option): Integer
    var
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
    begin

        case pAlterationOption of
          AlterationOption::RENEW : MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::RENEW;
          AlterationOption::UPGRADE : MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::UPGRADE;
          AlterationOption::EXTEND : MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::EXTEND;
          AlterationOption::CANCEL : MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::CANCEL;
          AlterationOption::REGRET : MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::REGRET;
          else
            Error ('Type must be selected.');
        end;

        exit (MembershipAlterationSetup."Alteration Type");
    end;

    local procedure AlterMemberships(CheckAndExecute: Boolean)
    var
        AlterationJnlMgmt: Codeunit "MM Alteration Jnl Mgmt";
        MemberInfoCapture: Record "MM Member Info Capture";
        SelectionCount: Integer;
    begin

        CurrPage.SetSelectionFilter (MemberInfoCapture);
        MemberInfoCapture.SetFilter ("Source Type", '=%1', MemberInfoCapture."Source Type"::ALTERATION_JNL);
        if (MemberInfoCapture.FindSet ()) then begin

          SelectionCount := MemberInfoCapture.Count();
          AlterationJnlMgmt.SetRequestUserConfirmation (SelectionCount = 1);

          if ((SelectionCount > 1) and (CheckAndExecute)) then
            if (not Confirm (CONFIRM_EXECUTE, true, SelectionCount)) then
              Error ('');

          repeat

            if (MemberInfoCapture."Response Status" in ["Response Status"::REGISTERED, "Response Status"::FAILED]) then begin
              MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::REGISTERED;
              AlterationJnlMgmt.AlterMembership (MemberInfoCapture);
              MemberInfoCapture.Modify();
              AlterationJnlMgmt.SetRequestUserConfirmation (false);
            end;

            if (CheckAndExecute) then begin
              if (MemberInfoCapture."Response Status" = MemberInfoCapture."Response Status"::READY) then begin
                AlterationJnlMgmt.AlterMembership (MemberInfoCapture);
                MemberInfoCapture.Modify();
              end;

              if (MemberInfoCapture."Response Status" = MemberInfoCapture."Response Status"::COMPLETED) then
                MemberInfoCapture.Delete();
            end;

          until (MemberInfoCapture.Next() = 0);
        end;

        CurrPage.Update(false);
    end;

    local procedure SelectMembershipUsingMemberCard(ExternalCardNumber: Text[100];var MemberInfoCapture: Record "MM Member Info Capture"): Boolean
    var
        MemberCard: Record "MM Member Card";
        Membership: Record "MM Membership";
    begin

        MemberCard.SetFilter ("External Card No.", '=%1', ExternalCardNumber);
        if (not MemberCard.FindFirst ()) then
          exit (false);

        if (MemberCard.Blocked) then
          MemberCard.TestField (Blocked);

        Membership.Get (MemberCard."Membership Entry No.");
        SetExternalMembershipNo (Membership."External Membership No.", MemberInfoCapture);
        exit (true);
    end;

    local procedure "--"()
    begin
    end;

    local procedure ImportAlterationFromFile(SkipFirstLine: Boolean)
    var
        FileManagement: Codeunit "File Management";
        SuggestFileName: Text[1024];
        FileName: Text[1024];
        Serverfilename: Text;
    begin

        //-MM1.44 [401040]
        SuggestFileName := '';
        FileName := FileManagement.OpenFileDialog (SELECT_FILE_CAPTION, SuggestFileName, FILE_FILTER);

        if (SuggestFileName = FileName) then
          Error ('');

        Serverfilename := FileManagement.UploadFileSilent(FileName);
        SetFileName (Serverfilename);

        ImportFromFile (SkipFirstLine);
        //+MM1.44 [401040]
    end;

    procedure SetFileName(PFileName: Text[250])
    begin

        //-MM1.44 [401040]
        GServerFileName := PFileName;
        //+MM1.44 [401040]
    end;

    procedure ImportFromFile(SkipFirstLine: Boolean)
    var
        TxtFile: File;
        IStream: InStream;
        MemberInfoCapture: Record "MM Member Info Capture";
        Fileline: Text;
        Window: Dialog;
        LowEntryNo: Integer;
    begin

        //-MM1.44 [401040]
        REQUIRED := 1;
        OPTIONAL := 2;

        GDateMask := 'YYYYMMDD'; // Should be setup or parameter

        TxtFile.TextMode (true);
        TxtFile.Open (GServerFileName);
        TxtFile.CreateInStream (IStream);

        if (not MemberInfoCapture.FindLast()) then ;
        LowEntryNo := MemberInfoCapture."Entry No." +1;

        if GuiAllowed then
          Window.Open (IMPORT_MESSAGE_DIALOG);

        while (not IStream.EOS) do begin

          if (IStream.ReadText (Fileline) > 0)  then begin
            //Fileline := Ansi2Ascii (Fileline);

            // UTF-8 files start with some bytes identifying the format, get rid of those bytes
            //IF (lineCount = 1) THEN WHILE (fileline[1] <> '"') DO fileline := COPYSTR (fileline, 2);

            DecodeLine (Fileline);

            if GuiAllowed then
              if ((GLineCount mod 5) = 0) then Window.Update (1, StrSubstNo (PROCESS_INFO, GLineCount, FldExternalNumber));

            GLineCount += 1;

            if ((SkipFirstLine) and (GLineCount <> 1)) or (not SkipFirstLine) then begin
              InsertLine ();
            end;

          end;

        end;

        TxtFile.Close ();
        if GuiAllowed then
          Window.Close ();
        //+MM1.44 [401040]
    end;

    local procedure DecodeLine(CsvLine: Text)
    begin

        //-MM1.44 [401040]
        FldAlterationType := nextField (CsvLine);
        FldExternalNumber := nextField (CsvLine);
        FldAlterationItemNo := nextField (CsvLine);
        FldAlterationDate := nextField (CsvLine);

        validateTextField (FldAlterationType, 20, REQUIRED, FieldCaption ("Information Context"));
        validateTextField (FldExternalNumber, MaxStrLen ("External Membership No."), REQUIRED, FieldCaption ("External Membership No."));
        validateTextField (FldAlterationItemNo, MaxStrLen ("Item No."), OPTIONAL, FieldCaption ("Item No."));
        validateDateField (FldAlterationDate, GDateMask, OPTIONAL, FieldCaption ("Document Date"));
        //+MM1.44 [401040]
    end;

    local procedure InsertLine()
    var
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        //-MM1.44 [401040]
        MemberInfoCapture.Init ();
        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::ALTERATION_JNL;
        MemberInfoCapture."Document No." := CopyStr (UserId, 1, MaxStrLen (MemberInfoCapture."Document No."));

        case LowerCase (FldAlterationType) of
          'renew'  : AlterationOption := AlterationOption::RENEW;
          'upgrade': AlterationOption := AlterationOption::UPGRADE;
          'extend' : AlterationOption := AlterationOption::EXTEND;
          'regret' : AlterationOption := AlterationOption::REGRET;
          'cancel' : AlterationOption := AlterationOption::CANCEL;
          else
            exit;
        end;
        SetInformationContext (AlterationOption, MemberInfoCapture);

        if (not SelectMembershipUsingMemberCard (FldExternalNumber, MemberInfoCapture)) then
          SetExternalMembershipNo (FldExternalNumber, MemberInfoCapture);

        if (MemberInfoCapture."Item No." = '') then
          validateTextField (FldAlterationItemNo, MaxStrLen ("Item No."), REQUIRED, FieldCaption ("Item No."));

        if (FldAlterationItemNo <> '') then
          SetItemNo (FldAlterationItemNo, MemberInfoCapture);

        MemberInfoCapture."Document Date" := Today;
        if (FldAlterationDate <> '') then
          MemberInfoCapture."Document Date" := validateDateField (FldAlterationDate, GDateMask, REQUIRED, FieldCaption ("Document Date"));

        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::REGISTERED;
        MemberInfoCapture."Originates From File Import" := true;

        MemberInfoCapture.Insert ();
        //+MM1.44 [401040]
    end;

    local procedure validateTextField(fieldValue: Text;fieldMaxLength: Integer;fieldValueIs: Integer;fieldCaptionName: Text): Text
    begin

        //-MM1.44 [401040]
        if (StrLen (fieldValue) > fieldMaxLength) then
          Error (INVALID_LENGTH, fieldValue, fieldMaxLength, fieldCaptionName, GLineCount);

        if ((fieldValue = '') and (fieldValueIs = REQUIRED)) then
          Error (VALUE_REQUIRED, fieldCaptionName, GLineCount);

        exit (fieldValue);
        //+MM1.44 [401040]
    end;

    local procedure validateDateField(fieldValue: Text;dateMask: Code[20];fieldValueIs: Integer;fieldCaptionName: Text) rDate: Date
    begin

        //-MM1.44 [401040]
        rDate := 0D;

        if ((fieldValue = '') and (fieldValueIs = REQUIRED)) then
          Error (VALUE_REQUIRED, fieldCaptionName, GLineCount);

        if ((fieldValue = '') and (fieldValueIs = OPTIONAL)) then
          exit (0D);

        if (StrLen (fieldValue) <> StrLen (dateMask)) then
          Error (INVALID_DATE, fieldValue, fieldCaptionName, GLineCount, dateMask);

        case UpperCase (dateMask) of
          'YYYYMMDD'   :
            if (not Evaluate (rDate, StrSubstNo ('%1-%2-%3', CopyStr (fieldValue, 1, 4), CopyStr (fieldValue, 5, 2), CopyStr (fieldValue, 7, 2)), 9)) then
              Error (INVALID_DATE, fieldValue, fieldCaptionName, GLineCount, dateMask);

          'YYYY-MM-DD' :
            if (not Evaluate (rDate, StrSubstNo ('%1-%2-%3', CopyStr (fieldValue, 1, 4), CopyStr (fieldValue, 6, 2), CopyStr (fieldValue, 9, 2)), 9)) then
              Error (INVALID_DATE, fieldValue, fieldCaptionName, GLineCount, dateMask);

          else
            Error (DATE_MASK_ERROR, dateMask);
        end;

        exit (rDate);
        //+MM1.44 [401040]
    end;

    local procedure validateIntegerField(fieldValue: Text;fieldValueIs: Integer;fieldCaptionName: Text) rInteger: Integer
    begin

        //-MM1.44 [401040]
        rInteger := 0;

        if ((fieldValue = '') and (fieldValueIs = REQUIRED)) then
          Error (VALUE_REQUIRED, fieldCaptionName, GLineCount);

        if ((fieldValue = '') and (fieldValueIs = OPTIONAL)) then
          exit (0);

        if not (Evaluate (rInteger, fieldValue)) then
          Error (INVALID_VALUE, fieldValue, fieldCaptionName, GLineCount);

        exit (rInteger);
        //+MM1.44 [401040]
    end;

    local procedure nextField(var VarLineOfText: Text[1024]) rField: Text[1024]
    begin

        //-MM1.44 [401040]
        exit (forwardTokenizer (VarLineOfText, ';', '"'));
        //+MM1.44 [401040]
    end;

    local procedure forwardTokenizer(var VarText: Text[1024];PSeparator: Char;PQuote: Char) RField: Text[1024]
    var
        Separator: Char;
        Quote: Char;
        IsQuoted: Boolean;
        InputText: Text[1024];
        NextFieldPos: Integer;
        IsNextField: Boolean;
        NextByte: Text[1];
    begin

        //-MM1.44 [401040]
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

        if ((VarText[1] = PQuote) and (StrLen (VarText) = 1)) then begin
          VarText := '';
          RField := '';
          exit (RField);
        end;

        IsQuoted := false;
        NextFieldPos := 1;
        IsNextField := false;

        InputText := VarText;

        if (PQuote = InputText[NextFieldPos]) then IsQuoted := true;
        while ((NextFieldPos <= StrLen (InputText)) and (not IsNextField)) do begin
          if (PSeparator = InputText[NextFieldPos]) then IsNextField := true;
          if (IsQuoted and IsNextField) then IsNextField := (InputText[NextFieldPos-1] = PQuote);

          NextByte[1] := InputText[NextFieldPos];
          if (not IsNextField) then RField += NextByte;
          NextFieldPos += 1;
        end;
        if (IsQuoted) then RField := CopyStr (RField, 2, StrLen (RField)-2);

        VarText := CopyStr (InputText, NextFieldPos);
        exit (RField);
        //+MM1.44 [401040]
    end;
}

