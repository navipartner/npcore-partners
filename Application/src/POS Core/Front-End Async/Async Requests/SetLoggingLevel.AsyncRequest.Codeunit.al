/// <summary>
/// Sets logging level for browser console and Major Tom. By default, all messages are logged
/// at INFO level, which includes all user-level messages (clicks, text entries, ...) and some
/// relevant system-generated messages. If you need more restrictive or less restrictive logging
/// per session (or for POS Unit, Salesperson, etc.) you can send this front-end request to
/// change the logging level for the current POS session.
/// 
/// Read more about debugging and logging in Dragonglass wiki:
/// https://dev.azure.com/navipartner/Dragonglass/_wiki/wikis/Dragonglass.wiki/89/Debugging-with-Workflows-2.0
/// </summary>
codeunit 6014659 "NPR Front-End: SetLoggingLevel" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _loggingLevel: Integer;

    /// <summary>
    /// Sets the front-end logging level to a new level. Levels are:
    /// * 0 VERBOSE
    /// * 1 LOG
    /// * 2 INFO
    /// * 3 WARNING
    /// * 4 ERROR
    /// * 5 CRITICAL
    /// </summary>
    /// <param name="Level"></param>
    procedure SetLoggingLevel(Level: Integer)
    begin
        _loggingLevel := level;
    end;

    procedure GetContent(): JsonObject;
    begin
        exit(_content);
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json.Add('Method', 'SetLoggingLevel');
        Json.Add('Level', _loggingLevel);
        Json.Add('Content', _content);
    end;
}
