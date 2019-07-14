pageextension 50036 pageextension50036 extends "User Setup" 
{
    // NPR5.38/MHA /20180115  CASE 302240 Added fields 6014405 "Allow Register Switch" and 6014410 "Register Switch Filter"
    // NPR5.46/MMV /20180913  CASE 290734 Removed deprecated fields.
    // NPR5.48/TS  /20181220  CASE 338956 Field User Setup has been added.
    // NPR5.49/ZESO/20190313  CASE 348556 Field E-mail Removed as it was already displayed.
    layout
    {
        addafter("Time Sheet Admin.")
        {
            field("Backoffice Register No.";"Backoffice Register No.")
            {
            }
            field("Allow Register Switch";"Allow Register Switch")
            {
            }
            field("Register Switch Filter";"Register Switch Filter")
            {
            }
        }
    }
}

