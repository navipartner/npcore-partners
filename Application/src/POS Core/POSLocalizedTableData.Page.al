page 6150724 "NPR POS Localized Table Data"
{
    Extensible = False;
    Caption = 'Localized Table Data';
    DataCaptionExpression = GetDataCaptionExpr();
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Localized Caption";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(CaptionForThisField; CaptionForThisField)
                {

                    Caption = 'Field';
                    Editable = false;
                    Style = Subordinate;
                    StyleExpr = Rec."From Original Table";
                    ToolTip = 'Specifies the value of the Field field';
                    ApplicationArea = NPRRetail;
                }
                field("Language Code"; Rec."Language Code")
                {

                    Editable = false;
                    Style = Subordinate;
                    StyleExpr = Rec."From Original Table";
                    ToolTip = 'Specifies the value of the Language Code field';
                    ApplicationArea = NPRRetail;
                }
                field("<Language Code>"; Rec.Caption)
                {

                    Editable = NOT Rec."From Original Table";
                    Style = Subordinate;
                    StyleExpr = Rec."From Original Table";
                    ToolTip = 'Specifies the value of the Caption field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Insert Language action';
                ApplicationArea = NPRRetail;

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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Delete Localization action';
                ApplicationArea = NPRRetail;

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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Apply Localization action';
                ApplicationArea = NPRRetail;

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
        CaptionFieldRef := RecRef.Field(Rec."Field No.");
        CaptionForThisField := CaptionFieldRef.Caption;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.TestField("From Original Table", false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ChangesMade := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Record ID" := RecRef.RecordId;
    end;

    trigger OnOpenPage()
    begin
        if RecRef.Number = 0 then
            Error(Text003);

        Rec.SetCurrentKey("Screen Sort Order", "Language Code", "Field No.");
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
        TempField: Record "Field" temporary;
        RecRef: RecordRef;
        Text001: Label 'You must provide the field list to localize, when preparing data for localization.\\Record ID: [%1]';
        Text002: Label 'must be ''Text'' when localizing captions for';
        Text003: Label 'You must not run this page directly. The only correct way to run this page is from the POS Menu Buttons page.';
        CaptionForThisField: Text;
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
        if LanguageDialog.RunModal() <> ACTION::LookupOK then
            exit;

        Old := Rec;

        TempField.FindSet();
        repeat
            Rec.Init();
            Rec."Record ID" := RecRef.RecordId;
            Rec."Language Code" := LanguageDialog.GetLanguageCode();
            Rec."Field No." := TempField."No.";
            Rec."From Original Table" := false;
            Rec.Insert();
        until TempField.Next() = 0;

        Rec := Old;
        CurrPage.Update(false);

        ChangesMade := true;
    end;

    local procedure DeleteLanguage()
    begin
        if Language."Abbreviated Name" = Rec."Language Code" then
            Error(Text004);

        if not Confirm(Text005, false, Rec."Language Code") then
            exit;

        Rec.SetRange("Language Code", Rec."Language Code");
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

            Rec.Init();
            Rec."Record ID" := LocalizeForRecordID;
            Rec."Field No." := Field."No.";
            Rec."Language Code" := Language."Abbreviated Name";
            Rec.Caption := Format(RecRef.Field(Field."No.").Value);
            Rec."Screen Sort Order" := -1;
            Rec."From Original Table" := true;
            Rec.Insert();

            TempField := Field;
            TempField.Insert();

            LocalizedCaption.SetRange("Record ID", RecRef.RecordId);
            LocalizedCaption.SetRange("Field No.", Field."No.");
            if LocalizedCaption.FindSet() then
                repeat
                    Rec := LocalizedCaption;
                    Rec.Insert();
                until LocalizedCaption.Next() = 0;
        until Field.Next() = 0;
    end;

    local procedure ApplyCaptions()
    var
        Caption: Record "NPR POS Localized Caption";
        Old: Record "NPR POS Localized Caption";
    begin
        TempField.FindSet();
        repeat
            Caption.SetRange("Record ID", RecRef.RecordId);
            Caption.SetRange("Field No.", TempField."No.");
            Caption.DeleteAll();
        until TempField.Next() = 0;

        Old := Rec;
        Rec.SetRange("From Original Table", false);
        if Rec.FindSet() then
            repeat
                Caption := Rec;
                Caption.Insert(true);
            until Rec.Next() = 0;
        Rec.SetRange("From Original Table");
        Rec := Old;

        ChangesMade := false;
    end;

    local procedure GetDataCaptionExpr(): Text
    var
        DataCaptionExprLbl: Label '%1 %2 (%3) - %4', Locked = true;
    begin
        exit(StrSubstNo(DataCaptionExprLbl, RecRef.Number, RecRef.Name, RecRef.Caption, RecRef.RecordId()));
    end;
}

