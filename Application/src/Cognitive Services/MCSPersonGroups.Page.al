page 6059957 "NPR MCS Person Groups"
{
    Extensible = False;
    Caption = 'MCS Person Groups';
    PageType = List;
    SourceTable = "NPR MCS Person Groups";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(PersonGroupId; Rec.PersonGroupId)
                {

                    ToolTip = 'Specifies the value of the Person Group Id field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Get Person Groups action';
                PromotedCategory = Process;
                PromotedOnly = true;
                Promoted = true;
                ApplicationArea = NPRRetail;
                trigger OnAction()
                begin
                    MCSFaceServiceAPI.GetPersonGroups();
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        MCSFaceServiceAPI: Codeunit "NPR MCS Face Service API";
}

