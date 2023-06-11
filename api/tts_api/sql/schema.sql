CREATE TABLE player_table(
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    player_id TEXT,
    player_name TEXT,
    player_avatar TEXT,
    player_email TEXT,
    save_data_json TEXT,
    flag INT(11) NOT NULL DEFAULT 1,
    create_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE prize_table(
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    prize_name TEXT,
    prize_image_url TEXT,
    prize_level INT(11),
    flag INT(11) NOT NULL DEFAULT 1,
    create_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE redeem_table(
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    prize_id INT(11) NOT NULL,
    player_id INT(11) NOT NULL,
    flag INT(11) NOT NULL DEFAULT 1,
    create_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (prize_id) REFERENCES prize_table(id),
    FOREIGN KEY (player_id) REFERENCES player_table(id)
);

CREATE TABLE banner_table(
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    banner_name TEXT,
    banner_image_url TEXT,
    flag INT(11) NOT NULL DEFAULT 1,
    create_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rank_table(
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    player_id TEXT,
    player_name TEXT,
    player_avatar TEXT,
    player_email TEXT,
    rank_level INT(11),
    flag INT(11) NOT NULL DEFAULT 1,
    create_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
