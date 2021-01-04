page 6150724 "NPR POS Localized Table Data"
{
    // NPR5.37/NPKNAV/20171030  CASE 290485 Transport NPR5.37 - 27 October 2017

    Caption = 'Localized Table Data';
    DataCaptionExpression = StrSubstNo('%1 %2 (%3) - %4', RecRef.Number, RecRef.Name, RecRef.Caption, RecRef.RecordId);
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Localized Caption";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(CaptionForThisField; CaptionForThisField)
                {
                    ApplicationArea = All;
                    Caption = 'Field';
                    Editable = false;
                    Style = Subordinate;
                    StyleExpr = "From Original Table";
                    ToolTip = 'Specifies the value of the Field field';
                }
                field("Language Code"; "Language Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Subordinate;
                    StyleExpr = "From Original Table";
                    ToolTip = 'Specifies the value of the Language Code field';
                }
                field("<Language Code>"; Caption)
                {
                    ApplicationArea = All;
                    Editable = NOT "From Original Table";
                    Style = Subordinate;
                    StyleExpr = "From Original Table";
                    ToolTip = 'Specifies the value of the Caption field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Insert Language")
            {
                Caption = 'Insert Language';
                Image = Language;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Insert Language action';

                trigger OnAction()
                begin
                    InsertLanguage();
                end;
            }
            action("Delete Localization")
            {
                Caption = 'Delete Localization';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Delete Localization action';

                trigger OnAction()
                begin
                    DeleteLanguage();
                end;
            }
            action("Apply Localization")
            {
                Caption = 'Apply Localization';
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Apply Localization action';

                trigger OnAction()
                begin
                    ApplyCaptions();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        CaptionFieldRef: FieldRef;
    begin
        CaptionFieldRef := RecRef.Field("Field No.");
        CaptionForThisField := CaptionFieldRef.Caption;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        TestField("From Original Table", false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ChangesMade := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Record ID" := RecRef.RecordId;
    end;

    trigger OnOpenPage()
    begin
        if RecRef.Number = 0 then
            Error(Text003);

        SetCurrentKey("Screen Sort Order", "Language Code", "Field No.");
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if ChangesMade then
            exit(Confirm(Text006))
        else
            exit(true);
    end;

    var
        Language: Record "Windows Language";
        FieldTmp: Record "Field" temporary;
        RecRef: RecordRef;
        Text001: Label 'You must provide the field list to localize, when preparing data for localization.\\Record ID: [%1]';
        Text002: Label 'must be ''Text'' when localizing captions for';
        Text003: Label 'You must not run this page directly. The only correct way to run this page is from the POS Menu Buttons page.';
        CaptionForThisField: Text;
        FieldCaption: Text;
        Text004: Label 'You cannot delete captions for the default language. They come from the original table, and are not editable.';
        Text005: Label 'Are you sure you want to delete all captions for language %1?';
        ChangesMade: Boolean;
        Text006: Label 'You have made changes to localizations that will be lost if you don''t apply them first. Are you sure you want to close this page?';

    local procedure InsertLanguage()
    var
        LanguageDialog: Page "NPR POS Select Lang. Dialog";
        Old: Record "NPR POS Localized Caption";
    begin
        LanguageDialog.LookupMode := true;
        if LanguageDialog.RunModal <> ACTION::LookupOK then
            exit;

        Old := Rec;

        FieldTmp.FindSet();
        repeat
            Init();
            "Record ID" := RecRef.RecordId;
            "Language Code" := LanguageDialog.GetLanguageCode();
            "Field No." := FieldTmp."No.";
            "From Original Table" := false;
            Insert();
        until FieldTmp.Next = 0;

        Rec := Old;
        CurrPage.Update(false);

        ChangesMade := true;
    end;

    local procedure DeleteLanguage()
    begin
        if Language."Abbreviated Name" = "Language Code" then
            Error(Text004);

        if not Confirm(Text005, false, "Language Code") then
            exit;

        Rec.SetRange("Language Code", "Language Code");
        Rec.DeleteAll();
        Rec.SetRange("Language Code");

        CurrPage.Update(false);

        ChangesMade := true;
    end;

    procedure PrepareLocalizationForRecord(LocalizeForRecordID: RecordID; var "Field": Record "Field" temporary)
    var
        LocalizedCaption: Record "NPR POS Localized Caption";
        FieldRef: FieldRef;
    begin
        RecRef.Get(LocalizeForRecordID);

        if not Field.FindSet() then
            Error(Text001, LocalizeForRecordID);

        Language.Get(GlobalLanguage);

        repeat
            FieldRef := RecRef.Field(Field."No.");
            if Format(FieldRef.Type) <> 'Text' then
                Field.FieldError(Type, Text002);

            Init();
            "Record ID" := LocalizeForRecordID;
            "Field No." := Field."No.";
            "Language Code" := Language."Abbreviated Name";
            Caption := Format(RecRef.Field(Field."No.").Value);
            "Screen Sort Order" := -1;
            "From Original Table" := true;
            Insert();

            FieldTmp := Field;
            FieldTmp.Insert();

            LocalizedCaption.SetRange("Record ID", RecRef.RecordId);
            LocalizedCaption.SetRange("Field No.", Field."No.");
            if LocalizedCaption.FindSet() then
                repeat
                    Rec := LocalizedCaption;
                    Insert();
                until LocalizedCaption.Next = 0;
        until Field.Next = 0;
    end;

    local procedure ApplyCaptions()
    var
        Caption: Record "NPR POS Localized Caption";
        Old: Record "NPR POS Localized Caption";
    begin
        FieldTmp.FindSet();
        repeat
            Caption.SetRange("Record ID", RecRef.RecordId);
            Caption.SetRange("Field No.", FieldTmp."No.");
            Caption.DeleteAll();
        until FieldTmp.Next = 0;

        Old := Rec;
        SetRange("From Original Table", false);
        if FindSet then
            repeat
                Caption := Rec;
                Caption.Insert(true);
            until Next = 0;
        SetRange("From Original Table");
        Rec := Old;

        ChangesMade := false;
    end;
}

