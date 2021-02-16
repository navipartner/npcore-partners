page 6059957 "NPR MCS Person Groups"
{
    Caption = 'MCS Person Groups';
    PageType = List;
    SourceTable = "NPR MCS Person Groups";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(PersonGroupId; Rec.PersonGroupId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Group Id field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Get Person Groups")
            {
                Caption = 'Get Person Groups';
                Image = Refresh;
                ApplicationArea = All;
                ToolTip = 'Executes the Get Person Groups action';
                PromotedCategory = Process;
                PromotedOnly = true;
                Promoted = true;
                trigger OnAction()
                begin
                    MCSFaceServiceAPI.GetPersonGroups;
                    CurrPage.Update;
                end;
            }
        }
    }

    var
        MCSFaceServiceAPI: Codeunit "NPR MCS Face Service API";
}

