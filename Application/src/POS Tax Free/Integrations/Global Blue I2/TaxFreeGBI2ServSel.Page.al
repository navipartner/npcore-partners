page 6059948 "NPR Tax Free GB I2 Serv. Sel."
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB I2 Service Select';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    InstructionalText = 'Select which global blue tax free service should be used';
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Tax Free GB I2 Service";
    SourceTableTemporary = true;

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
            }
        }
    }

    actions
    {
    }
}

