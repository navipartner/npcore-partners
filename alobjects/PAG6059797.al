page 6059797 "E-mail Attachments"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page contains fixed Attachments connected to E-mail Templates.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    AutoSplitKey = true;
    Caption = 'E-mail Attachments';
    PageType = List;
    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "E-mail Attachment";
    SourceTableView = SORTING("Table No.","Primary Key","Line No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Files';
                field("Line No.";"Line No.")
                {
                    Visible = false;
                }
                field("Attached File";"Attached File")
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
    }
}

