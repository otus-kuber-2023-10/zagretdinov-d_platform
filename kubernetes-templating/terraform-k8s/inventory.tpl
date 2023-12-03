[master]
${names[0]} ansible_host=${addrs[0]}

[workers]
%{ for i in range(length(names) - 1) ~}
${names[i + 1]} ansible_host=${addrs[i + 1]}
%{ endfor ~}