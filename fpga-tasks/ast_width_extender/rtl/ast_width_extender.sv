module ast_width_extender #(
  parameter DATA_IN_W   = 64,
  parameter EMPTY_IN_W  = $clog2(DATA_IN_W/8) ?  $clog2(DATA_IN_W/8) : 1,
  parameter CHANNEL_W   = 10,
  parameter DATA_OUT_W  = 256,
  parameter EMPTY_OUT_W = $clog2(DATA_OUT_W/8) ?  $clog2(DATA_OUT_W/8) : 1
)(
  input                            clk_i,
  input                            srst_i,

  input [DATA_IN_W-1:0]            ast_data_i,
  input                            ast_startofpacket_i,
  input                            ast_endofpacket_i,
  input                            ast_valid_i,
  input [EMPTY_IN_W-1:0]           ast_empty_i,
  input [CHANNEL_W-1:0]            ast_channel_i,
  output                           ast_ready_o,

  output logic [DATA_OUT_W-1:0]    ast_data_o,
  output logic                     ast_startofpacket_o,
  output logic                     ast_endofpacket_o,
  output logic                     ast_valid_o,
  output logic [EMPTY_OUT_W-1:0]   ast_empty_o,
  output logic [CHANNEL_W-1:0]     ast_channel_o,
  input                            ast_ready_i
);


`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "ModelSim" , encrypt_agent_info = "10.5b"
`pragma protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`pragma protect key_block
dV0z2ds5AQHaWtLkOgUyFiVE/DrUkbFezVQTfxwrrAhW8vgqfJB5WbUAJLVeC3GC
x6QjPfMEO9VL1dclbNrUsWO6XPDHJrkuEvEcTW7CxL1U9ECUEJi2qzxmlSWuDGP9
EURSPAB3MDJhgbaDS+dwvghQ5I2LXx/Lkvp2AYDJ64mm9KUSVEev4S1SQO+9C+2+
nwBfnwaVe53iqPkLo/nGirY9vyxhCLJalBw1XQ3npOYzc8vnmMWe+nuhFYMqE6Hp
Lt+nAq6A6T/1doVzAJ+R6S7upvyTKItoAzjcHurm/+lS930IArSxjdRVvsOIkFxu
1dIiAoidV/syCOiXmNI9ow==
`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 3840 )
`pragma protect data_block
blRVryVbOh6aalFGMutvIJGtPqoEa3HFPdyvQLYbrN24w8uTvS0R4WyrUqrPonus
q4CFCHy0grsmrPRy2QYypoZu7Oiitb6emt0AGGb0TQWyW6RlMsZdBtv+twBha2c5
JSYAHi0Ad+cPg+5wSJfODcYtrtHaDqNHbNlg72/qXFt6cE8a/p0GR4xZoLEdnsdk
1hLRo4BcBjDc/yZS+NT/RlNW+dHQJKOqsju88CHBmD6O9dlhirjQZ6n8X5dqc0yQ
2CRHVNAN87J4qQRn7ebMyenvABeHR7o/UQfYpNUk7OqRSU+e370uaRRs7eJIvERV
gjo+U5Ac1v/pxFPjqwg/ZF+kb+Jre89qwjySk0HZryxLyhNvNygMumoA5YibLMWA
dnGcrePbYCqNEenpV/3OK+D5SLlqjw+08pjyLG059fb5aAlHmM7OGTeSCsEIhpXy
usRllDNdEAZ4NtKo4o4a2N+weujW3aetw1Ds0oG2/x2GBmJ/2tC6jnAkn/EZMdyF
Fs/WbqjMxOnI4G4glOS3tgZtoxKFwRugsxwJjrWwcRbW6jnGlQg1uc680RaRNMMK
sZcZKg5AOXVktmNYYvL/pw6wWGbmWOXwLY0ek/DIjegh8W5alopgpPkTsY8jbR0d
RtpzplI1wKFAnWXuSgtu2G7mHRa8Nalz3Msl0VS8BWQquSVNsyCAoXkLOR6tsTms
dNno3tBu4sQmUKdJnTqSg+whFPfRAE+W2bKykvkZ7qxO7d4NZ604/D80Gym06P4v
INw28Z9vVMWDjSAjxpWMlZySQqZHjRMZd8Aq8UeTpllnWHCbzKdFJZHQ+1MsuZtz
IzwJVHI2fcWkme8Gr/EUZVUlaSbVszDSrpLisfQwfyY9X6tUtEoA6zVdfrPKUD0Q
j7wdalm4YJnC9TLk5JJQBNQWUBKl1X/U5trukyONS2UMQaUuEMjpmuvo40UYuljA
L9bw3aEADubZwJ0EvfLebtQqGtqPxACElAbT3SK4IO5Agy2/zO1hs+0FZFmeIJOI
caUtlsDNFQQQqn2bi7Fr4NMPudhYdLBAvDAaQFg8EjyJOusDVQ8e0yiqYCGlSKoJ
it337kNQtgMB/vKFKYJ9J2/t2/wkd0E3hFSHQA9NHhwPb4FJgsZwuhez781yx0T6
5aNxC5MJ6Ep+xzdzwksl/KRq5EOuSq2z7j9+aXyzz92+PSZ0jsoU3LW/tyqsWriN
IQeOdbwkmUHuso1UoAxdy7Q45xkE8od3+15/4vBSjqZQdhelbT6F8urwCsvbjJJf
31PmxGAmXGpbbKi9yvzeDrVOWCyF+C6s8PSb1M34JSj4aGSAqSA/5MO3hGBez0vX
aQ+URKrGqAmJ6INGoIaJC9IvaNhLO2mO39I7N5NRtpoY0DDAG3jfj7Vsasv958+g
/9VnZ99LSprk9mfLCnu0BHItuGM6JPyI9PvoznITWnv4LHxBZbhJs8NXpFXhyl0E
xD7CHo6fvb/uaoxpjAPmYcxJ3y/ALdNJJtTJSSdZ0EGhGGWhUmkiuz4dmHZq4MBs
HFLm8hFp5yNOzbQpcZyaom0uibnqYn7oO9Kb+Gd8hS+FsDgo1D6hqDhOWFc4RsKF
Fcst+sAwTo0nD2e+u1V6/1KXojz1xsmhwnsp1I3jER6kKITP9qwTdQQc1ytEjI6V
jSv4w0nGGtwZ1cSRPw4htTdh8gea8jIAXpBf8VDiuIe+w8Oasq/hDkoLF+0ZkwKZ
bBX/M7J0HbZPF/wGJX3AGDJe1JQhYwFyNIJLDuVJowKdrhF6EPVABMOVKpZwYPCQ
C7KESh0dowKPo+GC3vU/Ky+/mGp6T4JthVv76vQJd0Itt2wnn13IrzY4PTCSVcJ+
6xOwkIP/zq/pcHMSsFtRP429x7E3TKVH5z99HPMa5GLFuhwB3yZr0GvOLBSvcHqG
lJZ82wEjyle/tXgIpV6NI7pwTcgAUxqvnuE/m1VvTv7cwzRPK2Yod3HBB7Bbt77U
z0+9s4WnfJIr4dxkm54qS84M8Pjgyd0Erx+KYO8Vr/gMi+oloaCI0L58LTjzNNBh
gl4qXRo8MXll3beY/TrWo0zOFmV3/arX0JVak1+sAixV0otNAFHNTxxok+6nIVYK
pKT/HEX+ADTF7v49skYXW2SOd/pfoSQPy+0KELW+NDnOsWp9r3ZiFAmkzK1BIGIB
gO+kieHzUYzQKHbOQYgN38qSYgu2lKCDGIeKn+9i7qatmT4EvEPWun2bqkFdM5QM
OFEVHYPv4Cus2WgDWKakVzcbIrKEeflflG9TOov9+WSxo+XOEL3Kkg2mb4+dbLDX
K4GDPeUZnMDknF4sUJXrvm62/RtSYYnOhaYxCgsfzQc5HLL+s9DRZHXZ/ykwvn3b
HZYTrg+nbuJiM72Lcarv7Uc3f0keCaXz45P6FUaS+FekgkX85qgPPHsWtG+TQC7Z
o4QGNQmiYSmwoRPlYHCtWGTcJhq4bzv9WBqwGDupufflCrXqZdfBwr9vySefo7L7
8oroE3I7CedtWaOeA1BHbmoZJNOSXBdASv6+X/dsJWDNZdTxBgzHNMpreCL6aJ6C
qx3arGPcC2U06wj1XMmNozadvb9sVUEUcSx5qOvuoS36PjcFYvBkn7eJoOdjn2Nb
qVzHpbIbNbb1YsWLgbRiYrhyp44GBVZl4lhxsS56+vM164RPfoE3pPxdeoR80uE0
AVdMDY8Ug9Kcvi/R3XfCxWAF0CAS4f6VkwYzDoV+X5eKSe2Z/CcguafYZvYhLDFs
MvjKt3YZ9e04OmHy9V4ALOGH2jHP/zlolEsGyUMy1lJj7fO3TagrtpStyav6iONn
VZSGLqRJr+Dz/M1/Byfc94n9+Qo7eViBOlHLvvHcpUjGyGeprq8rpD/q9ZpdHsls
es0Bkv9/p8XIlxJ6Cqpw5dmiyYHDSGNRfscVLOx20XjtQWr8xH4PCneG5PLd4c1G
L0q5Rx8HMsGeyWy7CALQSNlSAoPJdlEi7wJ5vPBb2Dvd2Sqo2o+nqO/MX7xTzBOP
dtxF9RlA70BTiiiD418zBUASPV7R93jhJ2I4JkrzD9kM7I7gcgmyi9XeUcHeWc1E
XhTP6OZN+r6w9iIypjqv1iwJo0X7+D6MrPrgnD14MjAV0X8hgjlJVFeSNbO8O10N
0AC6hzAWBAL+3f3fDxZSGSi9GHi0yDbwKKp2LeWSv6kfUwLpfS+0zapCk7rvoPtp
uG8beGOI4zSnJadoQeC1Kjrp9524sD+NDz9nHTQZDLo+2mPnXEEjtJJPjLnnQ3pU
SaSla7eyqs0sVVkmySQIp1gKAe/55QLnPiubUHnZDpMgSgc9c5Q3vccvqb2qRT46
EyrNvkLQQ16cTJiu7R5QLAQXkjVSrXccE6SXw2OxEfxDAJ+iFnsOwfqj7mFRFcso
ARW1YQG8eCIKovc6fHZb8zeme6eF7pF18ee3GjXdbLYfaEUlPtzvFu7bzOyfxEQ7
af8mXh1K3nAUqr0SM1tPxcbDTH8zONzO6LbfjWcXZxUfVSJmih2m5O2Me18/ZIZA
T6WFpyEPDDumyG1H+32GHHIlJgodPR7xikGW7CK587QYXsL8x2YMhW5DQ4I6kk4F
klmbEUGy4Jgo+JULXaJODNPXRmsLslMTOHIgo9loYfuSDcj8bvQyCqMclFEH8D3W
DM1Zd0RjOmFIVB5IqtMAftmhX7hw10gRJy83MCptdpOhCRDhS5W6i31XlkAZK1qa
D/Q7e19ezkjRv4i25B8QHaE5+oNSmdphIUlhbPcaquiJXrKE+KrErWUo3+u63pY8
uKJNvagoeGSjSeHK6RNr6MIxzSWqfV59GiM9TYkaGbwxuL1KSkOSzSu6tkKYpxR5
Hz1GtCeyUiKclAPWt59X4swrbVuBz0LRQN8wDOeGuCbDVjDcGS8GpxSZgeL3zJDy
an7NS4ESZQ0939oUFz0DRPZEHNp9CSvK8D4fWbkjMDDoCXn6kaVWUwNGRHFwSJX0
KhoiTm+QL7oDddSEoGzXA3SD34duSEYF50MowOc1IG+Msj3qjK5uqihqz2kGla3l
kHXGsftqwwxjzK0NIpQUJ5OhUd3bqVk3+CZCRv5RhfpW7mUSzcG6X4dROVhpmDk7
TMCyHXBONf66v1nBi08fZcklXkuZWQEhiRk6axL9kqXTIKD0dpdbaZ2skaCKVfLI
X1d2z+xk2y1Ahy5PV32b5+9JhGYp0lOGSNcxhHHSo3giME8yHsva/slxWLOR/djR
P5REmpeiWx0f+cC+MvtpAOCkOAJVbvjbxoSiHjBj23WQl9JKcqJcoYRRyu4DmtiL
QHwiFWkEDKN/5AjLWpUcE6hW6Ep5j6py1jdbkM7xsO+Hq3Ictc2kHyrtFqZIlOFJ
wqYEJAcCe6SxS+12YZoLr4nHod9vRfvfCsmuiWli9WyYCWN3vTbPYIxIisbbb8/y
KACWfgrFyLDS/WlHOREHsXqywqBN2u2UmrTTuYXS4n3afd/SVLSQu3TwOhzEUks1
PNuw+UbQ8Mk/puCaKJRtYx5dHhUoodeqASrWaSHa9PhRQuGX4iHOIQ8zIvVWuMXA
lXzCtBLM9we9WgKV7uautR2FTtIZeRQYwHKtA4lyrKxptoGqy+k6Sl7Xz6UFCd1S
2mQ6ToGqflQfbqMRkzQH89l46hxRFOYRlhbIZhKtf0AQMV1dcysaq0l1JKaUjd+s
ychsYyS6mXI/YKyRAqTyvdVMlp4Ewa6o5SuEbaTlhWi16029mXJ7201260nwhHC5
PJdLc2kif95W1BH2du46n9zbGn07iBPfjVHpRDvPfGBl8nyI0+etmjkAhOKX0PqN
hTnXHI5ir901TdlM58YSWTRnqd8Y7At/xIsbhIrrZSenbVt2ujLVMcEdPbJuydog
7SgEjR//G75LxWzEoZ0D5nk89ZsVHvS+7sQsCtR2/U2KZxTrpS0Eb66oLsnTXXpX
EjO4XvoQpt8YBJHX0eZX13dgZoJG9/EYe8ss+8/NPeUXTeh5MXZJSTmgOESANTBQ
g6Oapa7Saggmh5ODv7oGE2haku9S3AbPHKl1ZQMiaWNmMysRfvOlrexMvmgbVgLw
LuFLwM6hF4eshzko9sODHzdysR+QieDt0kXrk3WHKLch4gcFYnNn8K576X6d0T1r
`pragma protect end_protected
