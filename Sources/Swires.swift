import raylib

let DARKBLUE = Color(r:   0, g:  82, b: 172, a: 255)
let YELLOW   = Color(r: 253, g: 249, b:   0, a: 255)
let DARKGREY = Color(r:  16, g:  16, b:  16, a: 255)
let BLACK    = Color(r:   0, g:   0, b:   0, a: 255)
let WHITE    = Color(r: 255, g: 255, b: 255, a: 255)

let WIDTH: Int32 = 800
let HEIGHT: Int32 = 600

let CELL: Int32 = 25
let CELL_WIDTH: Int32 = WIDTH / CELL
let CELL_HEIGHT: Int32 = WIDTH / CELL

enum Cell {
    case Empty
    case Conductor
    case HeadCharge
    case TailCharge

    init(fromNumber x: Int) {
        self = switch x {
        case 0: Cell.Empty
        case 2: Cell.HeadCharge
        case 3: Cell.TailCharge
        default: Cell.Conductor
        }
    }
}

var paused: Bool = false
var gridBuffer: [[[Cell]]] = [initGrid(), initGrid()]

let subGrid: [[Cell]] = [
    [0, 1, 1, 1, 1, 1, 1, 0,],
    [1, 0, 0, 0, 0, 0, 0, 1,],
    [1, 0, 0, 0, 0, 0, 0, 1,],
    [1, 0, 0, 0, 0, 0, 0, 1,],
    [0, 1, 1, 1, 1, 3, 2, 0,],
    [0, 0, 0, 0, 0, 0, 0, 0,],
    [0, 1, 1, 1, 1, 1, 1, 0,],
    [1, 0, 0, 0, 0, 0, 0, 1,],
    [1, 0, 0, 0, 0, 0, 0, 1,],
    [1, 0, 0, 0, 0, 0, 0, 1,],
    [0, 1, 1, 1, 1, 3, 2, 0,],
].map { x in x.map { n in Cell(fromNumber: n) } }

func initGrid() -> [[Cell]] {
    var result: [[Cell]] = []

    for _ in 0..<CELL_HEIGHT {
        var row: [Cell] = []
        
        for _ in 0..<CELL_WIDTH {
            row.append(Cell(fromNumber: 0))
        }

        result.append(row)
    }

    return result
}

func writeSubGrid<T>(leftOffset offsetX: Int = 0, topOffset offsetY: Int = 0, from subGrid: [[T]], to grid: inout [[T]]) {
    for (y, row) in subGrid.enumerated() {
        for (x, value) in row.enumerated() {
            grid[y + offsetY][x + offsetX] = value
        }
    }
}

func drawGrid() {
    for (y, row) in gridBuffer[0].enumerated() {
        for (x, value) in row.enumerated() {
            switch value {
                case .Conductor:  DrawRectangle(Int32(x) * CELL, Int32(y) * CELL, CELL, CELL, WHITE)
                case .HeadCharge: DrawRectangle(Int32(x) * CELL, Int32(y) * CELL, CELL, CELL, YELLOW)
                case .TailCharge: DrawRectangle(Int32(x) * CELL, Int32(y) * CELL, CELL, CELL, DARKBLUE)
                default: break
            }
        }
    }

    var x: Int32 = 0
    while x < WIDTH {
        DrawLine(x, 0, x, HEIGHT, DARKGREY)
        x += CELL
    }

    var y: Int32 = 0
    while y < HEIGHT {
        DrawLine(0, y, WIDTH, y, DARKGREY)
        y += CELL
    }
}

func countNeighbours(row: Int, column: Int) -> Int {
    var result = 0
    for y in -1...1 {
        for x in -1...1 {
            if x == 0 && y == 0 { continue }

            if gridBuffer[0][row + y][column + x] == .HeadCharge {
                result += 1
            }
        }
    }
    return result
}

func updateGrid() {
    for y in 1..<Int(CELL_HEIGHT - 1) {
        for x in 1..<Int(CELL_WIDTH - 1) {
            gridBuffer[1][y][x] = switch gridBuffer[0][y][x] {
                case .Empty: .Empty
                case .HeadCharge: .TailCharge
                case .TailCharge: .Conductor
                case .Conductor:
                if (1...2).contains(countNeighbours(row: y, column: x))
                    { .HeadCharge } else { .Conductor }
            }
        }
    }

    gridBuffer.swapAt(0, 1)
}

func changeCellOnClick() {
    if IsMouseButtonPressed(Int32(MOUSE_BUTTON_LEFT.rawValue)) {
        let x = GetMouseX()
        let y = GetMouseY()

        let row = Int(y / CELL)
        let col = Int(x / CELL)

        gridBuffer[0][row][col] =
        switch gridBuffer[0][row][col] {
            case .Empty: .Conductor
            default: .Empty
        }
    }
}

func pauseOnSpace() {
    if IsKeyPressed(Int32(KEY_SPACE.rawValue)) {
        paused = !paused
    }
}

@main
struct SwiresApp {
    static func main() {
        var counter = 1;
        writeSubGrid(leftOffset: 3, topOffset: 3, from: subGrid, to: &gridBuffer[0])

        InitWindow(WIDTH, HEIGHT, "Hello from Swift!")
        defer { CloseWindow() }

        SetTargetFPS(30)

        while !WindowShouldClose() {
            BeginDrawing()

            ClearBackground(BLACK)

            pauseOnSpace()
            changeCellOnClick()

            counter += 1
            counter %= 3
            if counter == 0 && !paused { updateGrid() }

            drawGrid()
            DrawFPS(5, 5)

            EndDrawing()
        }
    }
}
