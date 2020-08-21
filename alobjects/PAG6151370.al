page 6151370 "CS Users"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.48/CLVA  /20181109  CASE 335606 Added field "View All Documents"
    // NPR5.50/CLVA  /20190524  CASE 345567 Added Action "Warehouse Employees"

    Caption = 'CS Users';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "CS User";

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
                field(Password; Password)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
                field("View All Documents"; "View All Documents")
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
            action("Create QR Codes")
            {
                Caption = 'Create QR Codes';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MPOS QR Code List";
            }
            action("Warehouse Employees")
            {
                Caption = 'Warehouse Employees';
                Image = Employee;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Warehouse Employees";
            }
        }
    }
}

