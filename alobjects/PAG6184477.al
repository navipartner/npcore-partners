page 6184477 "EFT Type POS Unit BLOB Param."
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Type POS Unit BLOB Param.';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "EFT Type POS Unit BLOB Param.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ParameterName; ParameterName)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                }
                field(ParameterDescription; ParameterDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
                field("FORMAT(Value.HASVALUE)"; Format(Value.HasValue))
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Caption = 'Value';
                    Editable = "User Configurable";

                    trigger OnAssistEdit()
                    begin
                        LookupValue();
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetParameterName();
        SetParameterDescription();
    end;

    var
        ParameterName: Text;
        ParameterDescription: Text;

    local procedure SetParameterName()
    begin
        Clear(ParameterName);
        OnGetParameterNameCaption(Rec, ParameterName);
        if (ParameterName = '') then
            ParameterName := Name;
    end;

    local procedure SetParameterDescription()
    begin
        Clear(ParameterDescription);
        OnGetParameterDescriptionCaption(Rec, ParameterDescription);
    end;
}

