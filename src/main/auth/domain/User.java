package main.auth.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@Builder
public class User {
    private Long id;
    private String email;
    private String password_hash;
    private String username;
    private String full_name;
    private String phone_number;
    private String status;
    private boolean is_verified;

}
