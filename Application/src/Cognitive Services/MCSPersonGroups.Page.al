page 6059957 "NPR MCS Person Groups"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS Person Groups';
    Editable = false;
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
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(PersonGroupId; PersonGroupId)
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
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                begin
                    CognitivityFaceAPI.GetPersonGroups;
                    CurrPage.Update;
                end;
            }
        }
    }

    var
        CognitivityFaceAPI: Codeunit "NPR MCS Face Service API";
}

