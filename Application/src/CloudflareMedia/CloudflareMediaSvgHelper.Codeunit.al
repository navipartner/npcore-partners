codeunit 6151097 "NPR CloudflareMediaSvgHelper"
{
    Access = Internal;

    procedure NoPictureAvailableImage(): Text
    var
        NoPictureAvailable: Label '<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-camera-off"><line x1="1" y1="1" x2="23" y2="23"></line><path d="M21 21H3a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2z"></path><path d="M12 17a5 5 0 0 0 0-10c-1.38 0-2.63.56-3.54 1.46"></path><path d="M8.12 8.12a5 5 0 0 0 7.76 7.76"></path></svg>', Locked = true;
    begin
        exit(ToDataUrl(NoPictureAvailable));
    end;

    procedure SpinnerSvg() Spinner: Text
    begin
        Spinner :=
            '<svg width="40" height="40" viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg" fill="currentColor" aria-label="loading" role="img">' +
            '<!-- row 1 -->' +
            '<circle cx="20" cy="20" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0s" repeatCount="indefinite"/></circle>' +
            '<circle cx="60" cy="20" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.2s" repeatCount="indefinite"/></circle>' +
            '<circle cx="100" cy="20" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.4s" repeatCount="indefinite"/></circle>' +
            '<!-- row 2 -->' +
            '<circle cx="20" cy="60" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.2s" repeatCount="indefinite"/></circle>' +
            '<circle cx="60" cy="60" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.4s" repeatCount="indefinite"/></circle>' +
            '<circle cx="100" cy="60" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.6s" repeatCount="indefinite"/></circle>' +
            '<!-- row 3 -->' +
            '<circle cx="20" cy="100" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.4s" repeatCount="indefinite"/></circle>' +
            '<circle cx="60" cy="100" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.6s" repeatCount="indefinite"/></circle>' +
            '<circle cx="100" cy="100" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.8s" repeatCount="indefinite"/></circle>' +
            '</svg>';
        exit(ToDataUrl(Spinner));
    end;

    local procedure ToDataUrl(Svg: Text): Text
    var
        DataUrl: Label 'data:image/svg+xml,%1', Locked = true;
    begin
        exit(StrSubstNo(DataUrl, Svg));
    end;
}
