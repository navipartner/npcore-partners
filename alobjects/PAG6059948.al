page 6059948 "Tax Free GB I2 Service Select"
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
    SourceTable = "Tax Free GB I2 Service";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
            }
        }
    }

    actions
    {
    }
}

