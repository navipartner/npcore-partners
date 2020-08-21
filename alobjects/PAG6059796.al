page 6059796 "E-mail Log"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page contains a Log of every E-mail send by PDF2NAV.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR5.41/NPKNAV/20180427  CASE 300893-02 Transport NPR5.41 - 27 April 2018

    Caption = 'Mail And Document Log List';
    Editable = false;
    PageType = List;
    SourceTable = "E-mail Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Recipient E-mail"; "Recipient E-mail")
                {
                    ApplicationArea = All;
                }
                field("From E-mail"; "From E-mail")
                {
                    ApplicationArea = All;
                }
                field("E-mail subject"; "E-mail subject")
                {
                    ApplicationArea = All;
                }
                field(Filename; Filename)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sent Date"; "Sent Date")
                {
                    ApplicationArea = All;
                }
                field("Sent Time"; "Sent Time")
                {
                    ApplicationArea = All;
                }
                field("Sent Username"; "Sent Username")
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

