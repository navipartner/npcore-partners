page 6184890 "Server Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Server Overview';
    PageType = List;
    SourceTable = File;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Path;Path)
                {
                }
                field(Name;Name)
                {
                }
                field(Size;Size)
                {
                }
                field(Date;Date)
                {
                }
                field(Time;Time)
                {
                }
            }
        }
    }

    actions
    {
    }
}

