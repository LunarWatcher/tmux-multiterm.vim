" Boooooring bullshit
if exists('g:tmux_multiterm_loaded')
    finish
endif
" Meta to prevent re-loading several times
let g:tmux_multiterm_loaded = 1

if !exists('g:tmux_multiterm_socket')
    if !empty($TMUX)
        let g:tmux_multiterm_socket = split($TMUX, ',')[0]
    else
        let g:tmux_multiterm_socket = ""
    endif
endif

if !exists('g:tmux_multiterm_session')
    let g:tmux_multiterm_session = ".0"
endif

" Begin public interface
" ===========================================================
fun! TmuxTargetExecuteCommand(pane = -1, session = -1, ...)
    if (a:0 == 0)
        return
    endif
    if (a:0 != 1)
        let splice = a:000
    else
        let splice = split(a:1, ' ')
    endif

    if !empty(g:tmux_multiterm_session)

        let sess = '-t ' 
        if a:session != -1
            let sess .= a:session
        else
            let sess .= g:tmux_multiterm_session
        endif

        if a:pane != -1
            let sess .= '.' . a:pane
        endif
        if (sess != '-t ')
            let splice = insert(l:splice, l:sess, 1)
        endif
    endif

    call TmuxExecuteCommand(join(l:splice, ' '))
endfun

" Untargeted tmux command launch.
" If a command like send-keys is used in this without specifying the buffer
" and terminal, it may have unintended consequences.
" Use TmuxTargetExecuteCommand instead.
fun! TmuxExecuteCommand (...)
    if (a:0 == 0)
        return
    endif
    let termCommand = 'tmux '
    if !empty(g:tmux_multiterm_socket)
        let termCommand .= '-S ' . g:tmux_multiterm_socket
    endif

    let termCommand .= ' ' . join(a:000, ' ')

    echo system(termCommand)
endfun

fun! TmuxSendKeys(pane = -1, session = -1, ...)
    if (a:0 == 0)
        return
    endif
    call TmuxTargetExecuteCommand(a:pane, a:session, 'send-keys "' . join(a:000, ' ') . '" ENTER')
endfun

" ===========================================================
" End public interface
"
" Begin private interface
" ===========================================================

" ===========================================================
" End private interface

command! -nargs=1 SetTerm let g:tmux_multiterm_session = <f-args>
" Minor fix to SetTerm
command! -nargs=1 SetBuffer let g:tmux_multiterm_session .= '.' . <f-args>

command! TmuxListSessions call TmuxExecuteCommand("list-sessions")
command! -nargs=* TmuxSendToRunner call TmuxSendKeys(-1, -1, <f-args>)
