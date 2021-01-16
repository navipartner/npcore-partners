page 6059895 "NPR Data Log Setup Ignore List"
{
    UsageCategory = None;
    Caption = 'Data Log Setup Ignore List';
    DataCaptionExpression = PageCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No.';
                    Editable = false;
                    Lookup = false;
                    ToolTip = 'Specifies the number of the field.';
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Field Caption';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the caption of the field, that is, the name that will be shown in the user interface.';
                }
                field("Ignore Modification"; IgnoreMod)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ignore Modification';
                    ToolTip = 'Specifies whether changes made to this field will trigger the data log creation.';
                    Editable = PageIsEditable;
                    Enabled = PageIsEditable;

                    trigger OnValidate()
                    begin
                        UpdateRec;
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        PageIsEditable := CurrPage.Editable();
        GetRec;
        TransFromRec;
    end;

    trigger OnAfterGetRecord()
    begin
        GetRec;
        TransFromRec;
    end;

    trigger OnOpenPage()
    begin
        FilterGroup(2);
        SetRange(Class, Class::Normal);
        FilterGroup(0);
        PageCaption := Format(TableNo) + ' ' + TableName;
    end;

    var
        DataLogSetupField: Record "NPR Data Log Setup (Field)";
        IgnoreMod: Boolean;
        PageCaption: Text[250];
        PageIsEditable: Boolean;

    local procedure UpdateRec()
    begin
        GetRec;
        TransToRec;
        if not DataLogSetupField."Ignore Modification" then begin
            if DataLogSetupField.Delete then;
        end else
            if not DataLogSetupField.Modify then
                DataLogSetupField.Insert;
    end;

    local procedure GetRec()
    begin
        if not DataLogSetupField.Get(TableNo, "No.") then begin
            DataLogSetupField.Init();
            DataLogSetupField."Table ID" := TableNo;
            DataLogSetupField."Field No." := "No.";
        end;
    end;

    local procedure TransFromRec()
    begin
        IgnoreMod := DataLogSetupField."Ignore Modification";
    end;

    local procedure TransToRec()
    begin
        DataLogSetupField."Ignore Modification" := IgnoreMod;
    end;
}
