page 6059948 "NPR Tax Free GB I2 Serv. Sel."
{
    Caption = 'Tax Free GB I2 Service Select';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    InstructionalText = 'Select which global blue tax free service should be used';
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Tax Free GB I2 Service";
    SourceTableTemporary = true;
    UsageCategory = None;
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
            }
        }
    }
}

