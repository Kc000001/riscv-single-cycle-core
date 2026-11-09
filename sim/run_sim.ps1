# One-click simulation script for RISC-V Single-Cycle Processor
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Compiling RISC-V Single-Cycle Core with Icarus Verilog  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

iverilog -o sim/tb_top.vvp `
    rtl/alu.v `
    rtl/pc.v `
    rtl/pc_adder.v `
    rtl/register_file.v `
    rtl/instruction_memory.v `
    rtl/data_memory.v `
    rtl/sign_extend.v `
    rtl/mux2.v `
    rtl/mux3.v `
    rtl/main_decoder.v `
    rtl/alu_decoder.v `
    rtl/control_unit.v `
    rtl/riscv_single_cycle_top.v `
    tb/tb_top.v

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nCompilation Successful! Running simulation..." -ForegroundColor Green
    vvp sim/tb_top.vvp

    Write-Host "`nSimulation completed! Waveform generated at sim/riscv_top.vcd" -ForegroundColor Green
    Write-Host "To view waveform, run: gtkwave sim/riscv_top.vcd" -ForegroundColor Yellow
} else {
    Write-Host "`nCompilation failed!" -ForegroundColor Red
}

