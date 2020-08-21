page 6151455 "Magento Video Links"
{
    // MAG2.15/TS  /20180531 CASE 311926 Table Created for Magento Video Link
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Video Links';
    PageType = Worksheet;
    SourceTable = "Magento Video Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Video Url"; "Video Url")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        MagentoVideoLink: Record "Magento Video Link";
                    begin
                        if ((StrPos("Video Url", 'youtube.com') = 0) and (StrPos("Video Url", 'vimeo.com') = 0) and (StrPos("Video Url", 'youtu.be') = 0)) then
                            Error(Text00001);
                        if (StrPos("Video Url", 'http://') <> 0) or (StrPos("Video Url", 'https://') <> 0) then
                            exit;
                    end;
                }
                field(Sorting; Sorting)
                {
                    ApplicationArea = All;
                }
                field("Short Text"; "Short Text")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    var
        Text00001: Label 'Please enter a valid youtube or vimeo url ';
}

