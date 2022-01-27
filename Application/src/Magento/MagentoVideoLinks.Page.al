page 6151455 "NPR Magento Video Links"
{
    Extensible = False;
    Caption = 'Magento Video Links';
    PageType = Worksheet;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Video Link";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Video Url"; Rec."Video Url")
                {

                    ToolTip = 'Specifies the value of the Video Url field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (not (StrLen(Rec."Video Url") = 0) and (StrPos(Rec."Video Url", 'youtube.com') = 0) and (StrPos(Rec."Video Url", 'vimeo.com') = 0) and (StrPos(Rec."Video Url", 'youtu.be') = 0)) then
                            Error(Text00001);
                        if (StrPos(Rec."Video Url", 'http://') <> 0) or (StrPos(Rec."Video Url", 'https://') <> 0) then
                            exit;
                    end;
                }
                field("Sorting"; Rec.Sorting)
                {

                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRRetail;
                }
                field("Short Text"; Rec."Short Text")
                {

                    ToolTip = 'Specifies the value of the Short Text field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        Text00001: Label 'Please enter a valid youtube or vimeo url ';
}
