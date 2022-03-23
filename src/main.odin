package main

import "core:fmt"
import "core:strings"
import "core:math"
import "core:math/linalg"
import "core:testing"
import "core:mem"
import rl "vendor:raylib"

Phonic :: enum {
    UpTopLeft,
    UpTopRight,
    UpMiddle,
    UpBottomLeft,
    UpBottomRight,
    Left,
    Middle,
    LowTopLeft,
    LowTopRight,
    LowMiddle,
    LowBottomLeft,
    LowBottomRight,
    Prefix,
}
Phonics :: distinct bit_set[Phonic]

Empty :: Phonics{}
OuterOnly :: Phonics{.UpTopLeft, .UpTopRight, .Left, .LowBottomLeft, .LowBottomRight}
InnerOnly :: Phonics{.UpBottomLeft, .UpMiddle, .UpBottomRight, .Middle, .LowTopLeft, .LowMiddle, .LowTopRight}
A_Glass     :: Phonics{.UpTopLeft, .UpTopRight, .Left}
AR_Arm      :: Phonics{.UpTopLeft, .UpTopRight, .LowBottomLeft, .LowBottomRight}
AH_Swan     :: Phonics{.UpTopLeft, .Left}
AI_Guy      :: Phonics{.UpTopRight}
// todo(ashley): AW and UH?
AY_Bay      :: Phonics{.UpTopLeft}
E_End       :: Phonics{.Left, .LowBottomLeft, .LowBottomRight}
EE_Bee      :: Phonics{.UpTopLeft, .Left, .LowBottomLeft, .LowBottomRight}
EER_Beer    :: Phonics{.UpTopLeft, .Left, .LowBottomRight}
EH_The      :: Phonics{.UpTopLeft, .UpTopRight}
ERE_Air     :: Phonics{.Left, .LowBottomRight}
I_Bit       :: Phonics{.LowBottomLeft, .LowBottomRight}
IR_Bird     :: Phonics{.UpTopRight, .Left, .LowBottomLeft, .LowBottomRight}
OH_Toe      :: Phonics{.UpTopLeft, .UpTopRight, .Left, .LowBottomLeft, .LowBottomRight}
OI_Toy      :: Phonics{.LowBottomLeft}
OO_Too      :: Phonics{.UpTopLeft, .UpTopRight, .Left, .LowBottomLeft}
OU_Wolf     :: Phonics{.Left, .LowBottomLeft}
OW_How      :: Phonics{.LowBottomRight}
ORE_Your    :: Phonics{.UpTopLeft, .UpTopRight, .Left, .LowBottomRight}

B_Baby      :: Phonics{.UpMiddle, .LowTopRight}
CH_Chat     :: Phonics{.UpBottomLeft, .LowMiddle}
D_Dog       :: Phonics{.UpBottomRight, .LowTopLeft, .LowTopRight}
F_Fox       :: Phonics{.UpBottomRight, .LowTopLeft, .LowMiddle}
G_Gun       :: Phonics{.UpBottomRight, .LowTopRight, .LowMiddle}
H_Hop       :: Phonics{.UpMiddle, .LowTopRight, .LowMiddle}
J_Jam       :: Phonics{.UpMiddle, .LowTopLeft}
K_Kart      :: Phonics{.UpMiddle, .UpBottomRight, .LowTopRight}
L_Live      :: Phonics{.UpMiddle, .LowMiddle}
M_Man       :: Phonics{.LowTopLeft, .LowTopRight}
N_Net       :: Phonics{.UpBottomLeft, .LowTopLeft, .LowTopRight}
NG_Ring     :: Phonics{.UpBottomLeft, .UpMiddle, .UpBottomRight, .LowTopLeft, .LowMiddle, .LowTopRight}
P_Poppy     :: Phonics{.UpBottomRight, .LowMiddle}
R_Run       :: Phonics{.UpMiddle, .UpBottomRight, .LowMiddle}
S_Sit       :: Phonics{.UpMiddle, .UpBottomRight, .LowTopLeft, .LowMiddle}
SH_Shut     :: Phonics{.UpBottomLeft, .UpBottomRight, .LowTopLeft, .LowTopRight, .LowMiddle}
T_Tunic     :: Phonics{.UpBottomLeft, .UpBottomRight, .LowMiddle}
TH_Thick    :: Phonics{.UpBottomLeft, .UpMiddle, .UpBottomRight, .LowMiddle}
TH_This     :: Phonics{.UpMiddle, .LowTopLeft, .LowMiddle, .LowTopRight}
V_Vine      :: Phonics{.UpBottomLeft, .UpMiddle, .LowTopRight}
W_Wit       :: Phonics{.UpBottomLeft, .UpBottomRight}
Y_You       :: Phonics{.UpBottomLeft, .UpMiddle, .LowMiddle}
Z_Zit       :: Phonics{.UpBottomLeft, .UpMiddle, .LowMiddle, .LowTopRight}
ZH_Azure    :: Phonics{.UpBottomLeft, .UpMiddle, .UpBottomRight, .LowTopLeft, .LowTopRight}

PhonicTranslit :: struct {
    symbol: string,
    as_in: string,
    vowel: bool,
}

phonics_translit := map[Phonics]^PhonicTranslit {
    A_Glass = &{"A", "Glass", true},
    AR_Arm = &{"AR", "Arm", true},
    AH_Swan = &{"AH", "Swan", true},
    AI_Guy = &{"AI", "Guy", true},
    AY_Bay = &{"AY", "Bay", true},
    E_End = &{"E", "End", true},
    EE_Bee = &{"EE", "Bee", true},
    EER_Beer = &{"EER", "Beer", true},
    EH_The = &{"EH", "The", true},
    ERE_Air = &{"ERE", "Air", true},
    I_Bit = &{"I", "Bit", true},
    IR_Bird = &{"IR", "Bird", true},
    OH_Toe = &{"OH", "Toe", true},
    OI_Toy = &{"OI", "Toy", true},
    OO_Too = &{"OO", "Too", true},
    OU_Wolf = &{"OU", "Wolf", true},
    OW_How = &{"OW", "How", true},
    ORE_Your = &{"ORE", "Your", true},
    
    B_Baby = &{"B", "Baby", false},
    CH_Chat = &{"CH", "Chat", false},
    D_Dog = &{"D", "Dog", false},
    F_Fox = &{"F", "Fox", false},
    G_Gun = &{"G", "Gun", false},
    H_Hop = &{"H", "Hop", false},
    J_Jam = &{"J", "Jam", false},
    K_Kart = &{"K", "Kart", false},
    L_Live = &{"L", "Live", false},
    M_Man = &{"M", "Man", false},
    N_Net = &{"N", "Net", false},
    NG_Ring = &{"NG", "Ring", false},
    P_Poppy = &{"P", "Poppy", false},
    R_Run = &{"R", "Run", false},
    S_Sit = &{"S", "Sit", false},
    SH_Shut = &{"SH", "Shut", false},
    T_Tunic = &{"T", "Tunic", false},
    TH_Thick = &{"TH", "Thick", false},
    TH_This = &{"TH", "This", false},
    V_Vine = &{"V", "Vine", false},
    W_Wit = &{"W", "Wit", false},
    Y_You = &{"Y", "You", false},
    Z_Zit = &{"Z", "Zit", false},
    ZH_Azure = &{"ZH", "Azure", false},
}

phoneme_points :: [?]rl.Vector2{
    {0, 5},
    {2, 5},
    {1, 6},
    {1, 4},

    {0, 2},
    {2, 2},
    {1, 3},
    {1, 1},
}

phonic_centers := map[Phonic]rl.Vector2{
    .UpTopLeft = {0.5, 0.5},
    .UpTopRight = {1.5, 0.5},
    .UpMiddle = {1, 1},
    .UpBottomLeft = {0.5, 1.5},
    .UpBottomRight = {1.5, 1.5},
    .Left = {0, 2.5},
    .LowTopLeft = {0.5, 3.5},
    .LowTopRight = {1.5, 3.5},
    .LowMiddle = {1, 4},
    .LowBottomLeft = {0.5, 4.5},
    .LowBottomRight = {1.5, 4.5},
    .Prefix = {1, 5.5},
}

draw_dotted_line :: proc(from, to: rl.Vector2, dot_length: f32) {
    diff := to - from
    diff_len := linalg.length(diff)
    dir := linalg.normalize(from)
    count := i32(math.ceil(diff_len / dot_length))
    count += count % 2

    points := make([]rl.Vector2, count)
    defer delete(points)

    for i in 0..<count {
        points[i] = from + dir * dot_length * f32(i)
    }

    rl.DrawLineStrip(&points[0], i32(len(points)), rl.WHITE)
}

draw_part :: proc(phoneme: Phonics, part: Phonic, from, to: rl.Vector2, thickness : f32 = 4) {
    draw_part_no_point(phoneme, part, from, to, thickness)
    rl.DrawCircleV(from, 8, rl.WHITE)
    rl.DrawCircleV(to, 8, rl.WHITE)
}

draw_part_no_point :: proc(phoneme: Phonics, part: Phonic, from, to: rl.Vector2, thickness : f32 = 4) {
    if part in phoneme {
        rl.DrawLineEx(from, to, thickness, rl.WHITE)
    }
    else {
        rl.DrawLineEx(from, to, thickness, rl.DARKGRAY)
        //draw_dotted_line(from, to, 10)
    }
}

draw_part_either_no_point :: proc(phoneme: Phonics, a, b: Phonic, from, to: rl.Vector2, thickness : f32 = 4) {
    if a in phoneme || b in phoneme {
        rl.DrawLineEx(from, to, thickness, rl.WHITE)
    }
    else {
        rl.DrawLineEx(from, to, thickness, rl.DARKGRAY)
    }
}

GetGridVec :: proc(x, y: f32, sw, sh: f32, off: f32) -> rl.Vector2 {
    return rl.Vector2{x * sw + off, y * sh - off}
}

draw_part_point :: proc(from: rl.Vector2, node_rad: f32) {
    rl.DrawCircleV(from, node_rad, rl.WHITE)
}

get_phonic_nearest_to :: proc(point, origin, cell_size: rl.Vector2, node_rad: f32) -> (phonic: Phonic, sqrdist: f32) {
    nearest := Phonic.UpTopLeft
    min := f32(math.F32_MAX)
    for phonic, p in phonic_centers {
        grid_point := origin + GetGridVec(p.x, p.y, cell_size.x, cell_size.y, node_rad)
        sqr_distance := linalg.length2(grid_point - point)
        if sqr_distance  < min {
            min = sqr_distance 
            nearest = phonic
        }
        // hack(ashley) i cant be arsed to implement better mouse-over logic for the areas around the lines, so im doing this shit
        //              instead lmfao
        if phonic == .Left {
            grid_point = origin + GetGridVec(p.x, p.y + 0.75, cell_size.x, cell_size.y, node_rad)
            sqr_distance = linalg.length2(grid_point - point)
            if sqr_distance  < min {
                min = sqr_distance 
                nearest = phonic
            }

            grid_point = origin + GetGridVec(p.x, p.y - 0.75, cell_size.x, cell_size.y, node_rad)
            sqr_distance = linalg.length2(grid_point - point)
            if sqr_distance  < min {
                min = sqr_distance 
                nearest = phonic
            }
        }
    }
    return nearest, min
}

/* render_phonic
renders phoneme as rune, in a pattern like:
 /  \
 \ /
| |
 / \
\ /
 .
*/
draw_phoneme_no_points :: proc(phonics: Phonics, cell_h, cell_w: f32, node_rad: f32) {

    draw_part_no_point(phonics, .Left, GetGridVec(0, 5, cell_w, cell_h, node_rad), GetGridVec(0, 3.5, cell_w, cell_h, node_rad), 4)
    draw_part_no_point(phonics, .Left, GetGridVec(0, 3, cell_w, cell_h, node_rad), GetGridVec(0, 2, cell_w, cell_h, node_rad), 4)

    draw_part_either_no_point(phonics, .UpMiddle, .LowMiddle, GetGridVec(1, 4, cell_w, cell_h, node_rad), GetGridVec(1, 3.5, cell_w, cell_h, node_rad), 4)

    draw_part_no_point(phonics, .UpTopLeft, GetGridVec(0, 5, cell_w, cell_h, node_rad), GetGridVec(1, 6, cell_w, cell_h, node_rad))
    draw_part_no_point(phonics, .UpTopRight, GetGridVec(2, 5, cell_w, cell_h, node_rad), GetGridVec(1, 6, cell_w, cell_h, node_rad))
    draw_part_no_point(phonics, .UpMiddle, GetGridVec(1, 6, cell_w, cell_h, node_rad), GetGridVec(1, 4, cell_w, cell_h, node_rad))
    draw_part_no_point(phonics, .UpBottomLeft, GetGridVec(0, 5, cell_w, cell_h, node_rad), GetGridVec(1, 4, cell_w, cell_h, node_rad))
    draw_part_no_point(phonics, .UpBottomRight, GetGridVec(1, 4, cell_w, cell_h, node_rad), GetGridVec(2, 5, cell_w, cell_h, node_rad))

    draw_part_no_point(phonics, .LowTopLeft, GetGridVec(0, 2, cell_w, cell_h, node_rad), GetGridVec(1, 3, cell_w, cell_h, node_rad))
    draw_part_no_point(phonics, .LowBottomLeft, GetGridVec(0, 2, cell_w, cell_h, node_rad), GetGridVec(1, 1, cell_w, cell_h, node_rad))
    draw_part_no_point(phonics, .LowTopRight, GetGridVec(2, 2, cell_w, cell_h, node_rad), GetGridVec(1, 3, cell_w, cell_h, node_rad))
    draw_part_no_point(phonics, .LowMiddle, GetGridVec(1, 3, cell_w, cell_h, node_rad), GetGridVec(1, 1, cell_w, cell_h, node_rad))
    draw_part_no_point(phonics, .LowBottomRight, GetGridVec(1, 1, cell_w, cell_h, node_rad), GetGridVec(2, 2, cell_w, cell_h, node_rad))
}

draw_phoneme_points :: proc(cell_h, cell_w: f32, node_rad: f32) {
    for point in phoneme_points {
        draw_part_point(GetGridVec(point.x, point.y, cell_w, cell_h, node_rad), node_rad)
    }
}

draw_phoneme_target :: proc(phoneme: ^Phoneme, target: rl.RenderTexture2D, node_size: f32, with_points: bool) {
    rl.BeginTextureMode(target)
    defer rl.EndTextureMode()
    rl.ClearBackground(rl.BLANK)

    phonic := phoneme.phonic
    if !with_points && phonic == Empty {
        return
    }

    node_rad := node_size / 2.0
    cell_h := f32(phoneme.h - 2) / 6.0
    cell_w := f32(phoneme.w) / 2.0 - node_rad

    draw_phoneme_no_points(phonic, cell_h, cell_w, node_rad)
    if with_points {
        draw_phoneme_points(cell_h, cell_w, node_rad)
    }
    
    // draw center phrase line, which is omnipresent in phrases (usually). Here for convenience & ledgibility.
    rl.DrawLineEx(GetGridVec(0, 3.5, cell_w, cell_h, node_rad), GetGridVec(2, 3.5, cell_w, cell_h, node_rad), 6.5, rl.WHITE)

    prefix_pos := GetGridVec(1, 0.5, cell_w, cell_h, node_rad)
    prefix_pos.y += 1
    prefix_size := cell_h / 2.0 - node_rad
    prefix_color := rl.DARKGRAY
    if .Prefix in phonic {
        prefix_color = rl.WHITE
    } else if !with_points {
        return
    }
    rl.DrawCircleLines(i32(prefix_pos.x), i32(prefix_pos.y), prefix_size, prefix_color)
    rl.DrawCircleLines(i32(prefix_pos.x), i32(prefix_pos.y), prefix_size - 0.5, prefix_color)
    rl.DrawCircleLines(i32(prefix_pos.x), i32(prefix_pos.y), prefix_size - 1.0, prefix_color)
    rl.DrawCircleLines(i32(prefix_pos.x), i32(prefix_pos.y), prefix_size - 1.5, prefix_color)
    rl.DrawCircleLines(i32(prefix_pos.x), i32(prefix_pos.y), prefix_size - 2.0, prefix_color)
}

draw_phoneme :: proc(phoneme: ^Phoneme, node_size: f32, with_points: bool) {
    draw_phoneme_target(phoneme, phoneme.target, node_size, with_points)
}

draw_state :: proc(state: ^State) {
    working_phoneme := state.phrase[state.cursor]
    for phoneme in state.phrase {
        draw_phoneme(phoneme, state.node_size, false)
        if phoneme == working_phoneme {
            draw_phoneme_target(phoneme, state.active_target, state.node_size, true)
        }
    }
}

get_active_draw_components :: proc(state: ^State) -> (rl.Rectangle, rl.Rectangle, rl.Vector2) {
    working_phoneme := state.phrase[state.cursor]
    work_x := f32(rl.GetScreenWidth()) * 0.5
    work_y := f32(rl.GetScreenHeight()) * 0.67
    active_w := f32(state.active_target.texture.width)
    active_h := f32(state.active_target.texture.height)
    active_aspect := active_w / active_h
    active_src := rl.Rectangle{0.0, 0.0, active_w, active_h}
    active_dest := rl.Rectangle{work_x, f32(rl.GetScreenHeight()) - work_y * 0.5 - state.bottom_padding, work_y * active_aspect, work_y}
    active_origin := rl.Vector2{active_dest.width * 0.5, active_dest.height * 0.5}

    return active_src, active_dest, active_origin
}

get_phonic_translits :: proc(phonics: Phonics) -> (vowel, cons: ^PhonicTranslit) {
    vowel = nil
    cons = nil
    without_prefix := phonics - {.Prefix}
    for p, t in phonics_translit {
        if (without_prefix - OuterOnly) == p {
            assert(!t.vowel)
            cons = t
        } else if (without_prefix - InnerOnly) == p {
            assert(t.vowel)
            vowel = t
        }
    }
    return
}

render_state :: proc(state: ^State) {
    // render the whole state, which has a cursor & the offset, the phrase at the top, and the current working phoneme in the
    // bottom center third
    offset_x := f32(30.0)

    // draw phrase phonemes
    {
        phrase_loop: for phoneme in state.phrase {
            // draw blinking under cursor
            if phoneme == state.phrase[state.cursor] {
                cwidth := state.phrase_height * 0.5
                if math.mod(rl.GetTime(), 1.5) < 0.75 {
                    cfrom := rl.Vector2{offset_x, state.bottom_padding + state.phrase_height + 5}
                    cto := rl.Vector2{offset_x + cwidth, state.bottom_padding + state.phrase_height + 5}
                    rl.DrawLineEx(cfrom, cto, 5, rl.RAYWHITE)
                }
            }

            width := f32(phoneme.w)
            height := f32(phoneme.h)
            aspect := width / height
            src := rl.Rectangle{0.0, 0.0, width, height}
            phrase_height := state.phrase_height
            phrase_width := phrase_height * aspect
            if phoneme.phonic == Empty {
                offset_x += phrase_width * state.space_width_scale
                continue phrase_loop
            }

            dest := rl.Rectangle{offset_x, state.bottom_padding, phrase_width, phrase_height}
            origin := rl.Vector2{0, 0}

            rl.DrawTexturePro(
                phoneme.target.texture,
                src,
                dest,
                origin,
                0.0,
                rl.WHITE)

            vowel, cons := get_phonic_translits(phoneme.phonic)
            sound := ""
            // todo(ashley): tooltip with "as in" sounds
            if vowel != nil && cons != nil {
                // if prefix is specified, then vowel goes first
                if .Prefix in phoneme.phonic {
                    sound = fmt.tprintf("%v.%v", vowel.symbol, cons.symbol)
                } else {
                    sound = fmt.tprintf("%v.%v", cons.symbol, vowel.symbol)
                }
            } else if vowel != nil {
                sound = vowel.symbol
            } else if cons != nil {
                sound = cons.symbol
            }

            if len(sound) > 0 {
                sound_cstr := strings.clone_to_cstring(sound, context.temp_allocator)
                sound_width := rl.MeasureText(sound_cstr, 18)
                rl.DrawText(sound_cstr, i32(dest.x + dest.width * 0.5) - sound_width / 2.0, i32(dest.y) + i32(dest.height) - i32(origin.y) + i32(state.bottom_padding), 18.0, rl.WHITE)
            }
            
            offset_x += dest.width
        }
    }

    // draw active working phoneme
    {
        src, dest, origin := get_active_draw_components(state)
        rl.DrawTexturePro(
            state.active_target.texture,
            src,
            dest,
            origin,
            0.0,
            rl.WHITE)
    }
}

Phoneme :: struct {
    phonic: Phonics,
    target: rl.RenderTexture2D,
    w, h: i32,
}

State :: struct {
    phrase: [dynamic]^Phoneme,
    cursor: i32,
    phrase_height: f32,
    space_width_scale: f32,
    node_size: f32,
    active_target: rl.RenderTexture2D,
    bottom_padding: f32,
}

make_phoneme_texture :: proc(h: i32, aspect: f32 = 0.5, node_size: f32 = 16.0) -> (rl.RenderTexture2D, i32, i32) {
    w := i32(f32(h) * aspect + node_size)
    h := h + 2
    return rl.LoadRenderTexture(w, h), w, h
}

init_state :: proc(state: ^State) {
    state.cursor = 0
    state.phrase_height = 195.0
    state.space_width_scale = 0.5
    state.node_size = 16.0
    state.phrase = make([dynamic]^Phoneme, 0, 32)
    
    initial := new(Phoneme)
    init_phoneme(initial)

    append(&state.phrase, initial)

    state.active_target, _, _ = make_phoneme_texture(800)
    state.bottom_padding = 30
}

cleanup_state :: proc(state: ^State) {
    for phoneme in state.phrase {
        cleanup_phoneme(phoneme)
        free(phoneme)
    }
    delete(state.phrase)
    rl.UnloadRenderTexture(state.active_target)
}

init_phoneme :: proc(phoneme: ^Phoneme) {
    phoneme.phonic = Phonics{}
    phoneme.target, phoneme.w, phoneme.h = make_phoneme_texture(800)
}

cleanup_phoneme :: proc(phoneme: ^Phoneme) {
    rl.UnloadRenderTexture(phoneme.target)
}

update_input :: proc(state: ^State) {
    mouse_pos := rl.GetMousePosition()
    if mouse_pos.x >= 0 &&
        mouse_pos.y >= 0 &&
        mouse_pos.x <= f32(rl.GetScreenWidth()) &&
        mouse_pos.y <= f32(rl.GetScreenHeight()) {

        _, dest, origin := get_active_draw_components(state)
        node_rad := state.node_size / 2.0
        cell_h := f32(dest.height - 2) / 6.0
        cell_w := f32(dest.width) / 2.0 - node_rad
        
        nearest, sqr_distance := get_phonic_nearest_to(mouse_pos, rl.Vector2{dest.x - dest.width / 2.0, dest.y - dest.height / 2.0 + state.bottom_padding / 2}, rl.Vector2{cell_w, cell_h}, node_rad)
        if sqr_distance < 45 * 45 {
            rl.SetMouseCursor(.POINTING_HAND)
            if rl.IsMouseButtonPressed(.LEFT) {
                current := state.phrase[state.cursor]
                if nearest in current.phonic {
                    current.phonic -= {nearest}
                } else {
                    current.phonic += {nearest}
                }
            }
        } else {
            rl.SetMouseCursor(.DEFAULT)
        }
    }

    if rl.IsKeyPressed(.RIGHT) {
        state.cursor += 1
        new_phoneme := new(Phoneme)
        init_phoneme(new_phoneme)
        append(&state.phrase, new_phoneme)
    }
    if rl.IsKeyPressed(.LEFT) && state.cursor > 0 {
        prev := state.phrase[state.cursor]
        if prev.phonic == Empty && state.cursor == i32(len(state.phrase) - 1) {
            cleanup_phoneme(prev)
            pop(&state.phrase)
            free(prev)
        }
        state.cursor -= 1
    }
    if rl.IsKeyPressed(.BACKSPACE) {
        if state.cursor == 0 {
            state.phrase[state.cursor].phonic = Empty
        } else {
            prev := state.phrase[state.cursor]
            cleanup_phoneme(prev)
            pop(&state.phrase)
            free(prev)
            state.cursor -= 1
        }
    }
}

main :: proc() {
    defer mem.free_all(context.temp_allocator)

    rl.SetConfigFlags(rl.ConfigFlags{.MSAA_4X_HINT, .WINDOW_RESIZABLE, .WINDOW_HIGHDPI})
    rl.InitWindow(800, 800, "Tunician")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    state := State{}
    init_state(&state)
    defer cleanup_state(&state)

    state.phrase[0].phonic = B_Baby

    for !rl.WindowShouldClose() {

        update_input(&state)

        draw_state(&state)

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        render_state(&state)

        rl.EndDrawing()
    }
}
