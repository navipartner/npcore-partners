page 6059957 "MCS Person Groups"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS Person Groups';
    Editable = false;
    PageType = List;
    SourceTable = "MCS Person Groups";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
                field(PersonGroupId;PersonGroupId)
                {
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
        CognitivityFaceAPI: Codeunit "MCS Face Service API";
}

