page 6059957 "NPR MCS Person Groups"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS Person Groups';
    Editable = false;
    PageType = List;
    SourceTable = "NPR MCS Person Groups";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(PersonGroupId; PersonGroupId)
                {
                    ApplicationArea = All;
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

