page 6184477 "NPR EFTType POSUnit BLOB Param"
{
    Extensible = False;
    Caption = 'EFT Type POS Unit BLOB Param.';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR EFTType POSUnit BLOBParam.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ParameterName; ParameterName)
                {

                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(ParameterDescription; ParameterDescription)
                {

                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("FORMAT(Value.HASVALUE)"; Format(Rec.Value.HasValue()))
                {

                    AssistEdit = true;
                    Caption = 'Value';
                    Editable = Rec."User Configurable";
                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.LookupValue();
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
        Rec.OnGetParameterNameCaption(Rec, ParameterName);
        if (ParameterName = '') then
            ParameterName := Rec.Name;
    end;

    local procedure SetParameterDescription()
    begin
        Clear(ParameterDescription);
        Rec.OnGetParameterDescriptionCaption(Rec, ParameterDescription);
    end;
}

