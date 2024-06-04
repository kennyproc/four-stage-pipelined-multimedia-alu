def bin2(n):
    s = bin(n)
 
    # removing "0b" prefix
    s1 = s[2:]
    return s1

def main():
  file1 = open("mips_instructions.txt", "r")
  file2 = open("output.txt", "w")
  mach_code = ""
  while True:
    instruction = file1.readline()
    if not instruction:
      break
    if instruction.startswith("li"):
      instr_list = instruction.rsplit(" ")
      mach_code = "0" + str(bin2(int(instr_list[2]))).zfill(3) + str(bin2(int(instr_list[3]))).zfill(16) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("simals"):
      instr_list = instruction.rsplit(" ")
      mach_code = "10000" + str(bin2(int(instr_list[4]))).zfill(5) + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("simahs"):
      instr_list = instruction.rsplit(" ")
      mach_code = "10001" + str(bin2(int(instr_list[4]))).zfill(5) + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("simsls"):
      instr_list = instruction.rsplit(" ")
      mach_code = "10010" + str(bin2(int(instr_list[4]))).zfill(5) + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("simshs"):
      instr_list = instruction.rsplit(" ")
      mach_code = "10011" + str(bin2(int(instr_list[4]))).zfill(5) + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("slmals"):
      instr_list = instruction.rsplit(" ")
      mach_code = "10100" + str(bin2(int(instr_list[4]))).zfill(5) + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("slmahs"):
      instr_list = instruction.rsplit(" ")
      mach_code = "10101" + str(bin2(int(instr_list[4]))).zfill(5) + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("slmsls"):
      instr_list = instruction.rsplit(" ")
      mach_code = "10110" + str(bin2(int(instr_list[4]))).zfill(5) + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("slmshs"):
      instr_list = instruction.rsplit(" ")
      mach_code = "10111" + str(bin2(int(instr_list[4]))).zfill(5) + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("nop"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100000000000000000000000"
    elif instruction.startswith("shrhi"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100000001" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("au"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100000010" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("cntih"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100000011" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("ahs"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100000100" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("or"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100000101" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("bcw"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100000110" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("maxws"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100000111" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("minws"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100001000" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("mlhu"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100001001" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("mlhss"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100001010" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("and"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100001011" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("invb"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100001100" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("rotw"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100001101" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("sfwu"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100001110" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    elif instruction.startswith("sfhs"):
      instr_list = instruction.rsplit(" ")
      mach_code = "1100001111" + str(bin2(int(instr_list[3]))).zfill(5) + str(bin2(int(instr_list[2]))).zfill(5) + str(bin2(int(instr_list[1]))).zfill(5)
    file2.write(mach_code + '\n')

if __name__ == "__main__":
    main()

