// inspired by
// https://github.com/ruby/ruby/blob/trunk/process.c
// https://github.com/kylef/Curassow/blob/master/Sources/Curassow/Arbiter.swift#L54
#if os(Linux)
    import Glibc
    private let system_fork = Glibc.fork
#else
    import Darwin.C
    @_silgen_name("fork") private func system_fork() -> Int32
#endif

public struct Daemon {
    public enum ExitStatus {
        case Success
        case Failure(Int)
    }
    
    public static func daemonize() -> ExitStatus {
        let devnull = open("/dev/null", O_RDWR)
        if devnull == -1 {
            fatalError("can't open /dev/null")
        }

        let pid = system_fork()
        if pid < 0 {
            fatalError("can't fork")
        } else if pid != 0 {
            exit(0)
        }

        if setsid() < 0 {
            fatalError("can't create session")
        }
        
        for descriptor in Int32(0)..<Int32(3) {
            dup2(devnull, descriptor)
        }

        var status: Int32 = 0
        if waitpid(pid, &status, 0) != -1 {
            return status == 0 ? ExitStatus.Success : ExitStatus.Failure(Int(status))
        } else {
            fatalError("fail waitpid(3)")
        }
    }
}
