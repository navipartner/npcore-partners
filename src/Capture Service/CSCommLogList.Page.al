page 6151372 "NPR CS Comm. Log List"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS Communication Log List';
    CardPageID = "NPR CS Comm. Log Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR CS Comm. Log";
    SourceTableView = SORTING("Request Start")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field("Request Start"; "Request Start")
                {
                    ApplicationArea = All;
                }
                field("Request End"; "Request End")
                {
                    ApplicationArea = All;
                }
                field("Request Function"; "Request Function")
                {
                    ApplicationArea = All;
                }
                field("Internal Request"; "Internal Request")
                {
                    ApplicationArea = All;
                }
                field("Internal Log No."; "Internal Log No.")
                {
                    ApplicationArea = All;
                }
                field(User; User)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

